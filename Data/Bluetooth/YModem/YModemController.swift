import Combine
import Foundation
import os

// MARK: YMODEM Control byte definitions

private let SOH: UInt8 = 0x01 // Start Of Header
private let EOT: UInt8 = 0x04 // End Of Transfer
private let ACK: UInt8 = 0x06 // Acknowledgment
private let CAN: UInt8 = 0x18 // Communication Abort Notification
private let RQS_PKT: UInt8 = 0x43 // Request Packet ("C" YModem byte)

private let ABORT = [CAN, CAN]

// MARK: OTA-speficfic bytes definition

private enum OTARequest: UInt8 {
    case write = 0x57
    case read = 0x52
    case update = 0x55
    case compare = 0x54
}

private enum OTAResponse: UInt8 {
    case updateSuccess = 0x41
    case updateFailure = 0x42
}

private let blockLength = 133 // <SOH><blk #><255-blk #><--128 data bytes--><cksum>

// MARK: YMODEM Controller

class YModemController {
    private let transport: YModemTransportProtocol

    private var cancellables = Set<AnyCancellable>()
    private let logger = os.Logger(subsystem: "com.podbike.app.YModem", category: "YModemController")

    private var transferTask: Task<Void, Never>?

    init(transport: YModemTransportProtocol) {
        self.transport = transport
    }

    private func sendDataBytes(_ requestType: OTARequest, _ bytes: [UInt8], withResponse: Bool = false) {
        let data = Data([requestType.rawValue] + bytes)
        transport.sendYModemData(data, withResponse: withResponse)
    }

    private func sendControlBytes(_ requestType: OTARequest, _ bytes: [UInt8]) {
        let data = Data([requestType.rawValue] + bytes)
        transport.sendYModemControl(data)
    }

    private func readDataStream() async -> Data? {
        await read(stream: transport.dataStream)
    }

    private func readControlStream() async -> Data? {
        await read(stream: transport.controlStream)
    }

    private func read(stream: YModemStream) async -> Data? {
        var operation: AnyCancellable?
        var cancelContinuation: (() -> Void)?
        let onCancel = {
            cancelContinuation?()
            operation?.cancel()
        }
        return await withTaskCancellationHandler {
            guard !Task.isCancelled else { return nil }
            return await withCheckedContinuation { continuation in
                operation = stream
                    .sink(
                        receiveCompletion: { _ in
                            continuation.resume(returning: nil)
                        },
                        receiveValue: {
                            continuation.resume(returning: $0)
                        })
                cancelContinuation = {
                    continuation.resume(returning: nil)
                }
            }
        } onCancel: {
            onCancel()
        }
    }

    private func getBlockPayload(_ block: Data?) -> Data? {
        guard let block = block, isBlockValid(block) else { return nil }
        let dataBlock = block[3 ..< 128 + 3]
        let blockEnd = dataBlock.firstIndex(where: { $0 == 0 }) ?? dataBlock.endIndex
        return dataBlock[..<blockEnd]
    }

    private func isBlockValid(_ data: Data?) -> Bool {
        guard let data else { return false }
        return data.count == blockLength && data[0] == SOH && data[2] == 0xff - data[1]
        // TODO: - validate checksum
    }
}

// MARK: FrikarConfigProtocol

extension YModemController: FrikarConfigProtocol {
    func getFrikarConfig() async -> FrikarConfig? {
        sendDataBytes(OTARequest.read, [RQS_PKT])
        let header = await readDataStream()
        guard let headerData = getBlockPayload(header) else { return nil }
        let headerString = String(data: headerData, encoding: .utf8)
        let headerComponents = headerString?.split(separator: " ")
        if let headerComponents = headerComponents, headerComponents.count == 2 {
            let fileName = headerComponents[0]
            let fileSize = headerComponents[1]
            logger.info("Frikar config file: \(fileName), size: \(fileSize)B")
        }

        sendDataBytes(OTARequest.read, [ACK], withResponse: true) // Acknowledge header reception
        // await Task.sleep(millis: 100)
        sendDataBytes(OTARequest.read, [RQS_PKT]) // Request data

        var jsonString = ""
        readData: repeat {
            let data = await readDataStream()
            guard let blockPayload = getBlockPayload(data) else {
                break readData
            } // read payload
            let blockString = String(data: blockPayload, encoding: .utf8) ?? ""
            jsonString += blockString
            sendDataBytes(OTARequest.read, [ACK]) // Acknowledge block reception
        } while true

        if Task.isCancelled {
            sendDataBytes(OTARequest.read, ABORT)
            return nil
        }

        sendDataBytes(OTARequest.read, [ACK]) // Acknowledge EOT reception

        return try? JSONDecoder().decode(FrikarConfig.self, from: Data(jsonString.utf8))
    }
}

// MARK: OtaFileTransferProtocol

extension YModemController: OtaFileTransferProtocol {
    func transferFile(_ otaFile: OtaFile) -> OtaTransferProgress {
        let progress = OtaTransferProgress(0)

        transferTask?.cancel()
        transferTask = Task { @MainActor in
            let startTime = DispatchTime.now().uptimeNanoseconds

            do {
                try await fileTransferJob(otaFile) {
                    progress.value = $0
                }
            }
            catch {
                progress.send(completion: .failure(error))
            }

            let endTime = DispatchTime.now().uptimeNanoseconds
            let transferTimeSec = (endTime - startTime) / 1_000_000_000
            logger.info("File \(otaFile.fileName) with size \(otaFile.data.count)B transferred in \(transferTimeSec)s")

            progress.send(completion: .finished)
        }

        return progress
    }

    func abortTransfer() {
        transferTask?.cancel()
        transferTask = nil
    }

    @MainActor
    private func fileTransferJob(_ otaFile: OtaFile, progressCallback: (Double) -> Void) async throws {
        let fileName = otaFile.fileName
        let fileSize = otaFile.data.count

        sendControlBytes(OTARequest.write, [])
        try await waitForResponse(expectedBytes: [RQS_PKT])

        try await sendHeader(fileName: fileName, fileSize: fileSize)

        let chunkSize = 128
        var chunkOffset = 0
        var chunkIndex = 1
        repeat {
            let currentChunkSize = ((fileSize - chunkOffset) > chunkSize) ? chunkSize : (fileSize - chunkOffset)
            let chunk = otaFile.data.subdata(in: chunkOffset ..< chunkOffset + currentChunkSize)

            let dataPacket = createYModemPacket(data: chunk, packetNumber: chunkIndex)
            sendDataBytes(OTARequest.write, dataPacket)
            try await waitForResponse()

            chunkOffset += currentChunkSize
            chunkIndex += 1

            let progress = Double(chunkOffset) / Double(fileSize) * 100
            progressCallback(progress)
        } while chunkOffset < fileSize

        try await sendEot()
        try await sendNullPacket()
    }

    private func sendHeader(fileName: String, fileSize: Int) async throws {
        let headerPayload = "\(fileName)\0\(fileSize)"
        let headerData = headerPayload.data(using: .utf8) ?? Data()
        let headerPacket = createYModemPacket(data: headerData)
        sendDataBytes(OTARequest.write, headerPacket)
        try await waitForResponse()
    }

    private func sendEot() async throws {
        sendDataBytes(OTARequest.write, [EOT])
        try await waitForResponse(expectedBytes: [ACK])
        try await waitForResponse(expectedBytes: [RQS_PKT])
    }

    private func sendNullPacket() async throws {
        let nullData = Data(count: 128)
        let nullPacket = createYModemPacket(data: nullData)
        sendDataBytes(OTARequest.write, nullPacket)
        try await waitForResponse()
    }

    private func createYModemPacket(data: Data, packetNumber: Int = 0) -> [UInt8] {
        let paddedData = data.count == 128 ? data : data + Data(count: 128 - data.count)
        let seqenceNumber = UInt8(packetNumber % 256)
        let crc16 = paddedData.crc16ccitt()
        let dataBytes = [SOH, seqenceNumber, 255 - seqenceNumber] + paddedData.bytes + crc16.bytes
        return dataBytes
    }

    private func waitForResponse(expectedBytes: [UInt8] = [ACK]) async throws {
        let response = await readControlStream()
        if response != Data(expectedBytes) {
            await Task.sleep(millis: 100)
            sendDataBytes(OTARequest.write, ABORT)
            throw Task.isCancelled ? OtaUpdateError.transferCancelled : OtaUpdateError.transferError
        }
    }

    func runUpgrade() {
        let command = OTARequest.update.rawValue
        transport.sendYModemControl(Data([command]))
    }
}
