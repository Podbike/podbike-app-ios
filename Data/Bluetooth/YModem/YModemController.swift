import Combine
import Foundation
import os

// MARK: YMODEM Control byte definitions

private let SOH: UInt8 = 0x01 // Start Of Header
private let STX: UInt8 = 0x02 // Start Transmission
private let EOT: UInt8 = 0x04 // End Of Transfer
private let ACK: UInt8 = 0x06 // Acknowledgment
private let NACK: UInt8 = 0x15 // No Acknowledgment
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

class YModemController: YModemControllerProtocol {
    private let transport: YModemTransportProtocol

    let logger = os.Logger(subsystem: "com.podbike.app.YModem", category: "YModemController")

    init(transport: YModemTransportProtocol) {
        self.transport = transport
    }

    func getFrikarConfig() async -> FrikarConfig? {
        send(OTARequest.read, [RQS_PKT])
        let header = await read()
        guard let headerData = getBlockPayload(header) else { return nil }
        let headerString = String(data: headerData, encoding: .utf8)
        let headerComponents = headerString?.split(separator: " ")
        if let headerComponents = headerComponents, headerComponents.count == 2 {
            let fileName = headerComponents[0]
            let fileSize = headerComponents[1]
            logger.info("Frikar config file: \(fileName), size: \(fileSize)B")
        }

        send(OTARequest.read, [ACK]) // Acknowledge header reception
//        await Task.sleep(millis: 100)
        send(OTARequest.read, [RQS_PKT]) // Request data

        var jsonString = ""
        readData: repeat {
            let data = await read()
            guard let blockPayload = getBlockPayload(data) else {
                break readData
            } // read payload
            let blockString = String(data: blockPayload, encoding: .utf8) ?? ""
            jsonString += blockString
            send(OTARequest.read, [ACK]) // Acknowledge block reception
        } while true

        if Task.isCancelled {
            send(OTARequest.read, ABORT)
            return nil
        }

        send(OTARequest.read, [ACK]) // Acknowledge EOT reception

        return try? JSONDecoder().decode(FrikarConfig.self, from: Data(jsonString.utf8))
    }

    func runUpgrade() {
        let command = OTARequest.update.rawValue
        transport.sendYModemControl(Data([command]))
    }

    private func send(_ requestType: OTARequest, _ bytes: [UInt8]) {
        let data = Data([requestType.rawValue] + bytes)
        transport.sendYModemData(data)
    }

    private func read() async -> Data? {
        var operation: AnyCancellable?
        var cancelContinuation: (() -> Void)?
        let onCancel = {
            cancelContinuation?()
            operation?.cancel()
        }
        return await withTaskCancellationHandler {
            guard !Task.isCancelled else { return nil }
            return await withCheckedContinuation { continuation in
                operation = transport.dataStream
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
