import Combine
import Foundation

class OtaUpdateManager: OtaUpdateManagerProtocol {
    private let otaService: OtaServiceProtocol
    private let frikarConfigProvider: FrikarConfigProtocol
    private let fileTransferHandler: OtaFileTransferProtocol

    private var updateInfo: OtaUpdateInfo?

    init(otaService: OtaServiceProtocol,
         frikarConfigProvider: FrikarConfigProtocol,
         fileTransferHandler: OtaFileTransferProtocol)
    {
        self.otaService = otaService
        self.frikarConfigProvider = frikarConfigProvider
        self.fileTransferHandler = fileTransferHandler
    }

    func isUpdateAvailable() async throws -> Bool {
        guard let frikarConfig = await frikarConfigProvider.getFrikarConfig(), let frameNumber = frikarConfig.frameNumber else {
            throw OtaUpdateError.frikarConfigFetchError
        }
        let isUpdateAvailable = try await otaService.isUpdateAvailable(for: frikarConfig)

        if isUpdateAvailable {
            updateInfo = try await otaService.getOtaUpdateInfo(for: frameNumber)
        }

        return isUpdateAvailable
    }

    func getOtaUpdateLicense() async throws -> String {
        guard let updateInfo = updateInfo,
              let resource = updateInfo.resource.first,
              let licenseLink = resource.licenseLink
        else {
            throw OtaUpdateError.updateInfoMissing
        }

        let licenseFile = try await otaService.getLicenseFile(licenseLink)
        let licenseText = String(data: licenseFile, encoding: .utf8) ?? ""

        return licenseText
    }

    func downloadOtaUpdateFiles() async throws -> OtaUpdateFiles {
        guard let updateInfo = updateInfo,
              let resource = updateInfo.resource.first
        else {
            throw OtaUpdateError.updateInfoMissing
        }

        let otaUpdateFiles = try await withThrowingTaskGroup(of: (OtaFileType, String, Data).self) { group in
            let firmwareFiles = resource.firmwareModules?.map(\.fileName).compactMap { $0 } ?? []
            let audioFiles = updateInfo.audioFiles?.compactMap { $0 } ?? []

            for fileName in firmwareFiles {
                group.addTask {
                    let fileData = try await self.otaService.getFirmwareFile(fileName)
                    return (OtaFileType.firmware, fileName, fileData)
                }
            }

            for fileName in audioFiles {
                group.addTask {
                    let fileData = try await self.otaService.getAudioFile(fileName)
                    return (OtaFileType.audio, fileName, fileData)
                }
            }

            let otaFiles = try await group.reduce(into: [OtaFile]()) { array, result in
                let otaFile = OtaFile(type: result.0, fileName: result.1, data: result.2)
                array.append(otaFile)
            }

            return OtaUpdateFiles(
                firmwareFiles: otaFiles.filter { $0.type == OtaFileType.firmware },
                audioFiles: []
            )
        }

        return otaUpdateFiles
    }

    func transferFile(_ otaFile: OtaFile) -> OtaTransferProgress {
        fileTransferHandler.transferFile(otaFile)
    }

    func abortTransfer() {
        fileTransferHandler.abortTransfer()
    }

    func runUpgrade() {
        // TODO: - error handling, status handling
        fileTransferHandler.runUpgrade()
    }
}

enum OtaUpdateError: Error {
    case frikarConfigFetchError
    case updateInfoMissing
    case downloadError
    case transferError
    case transferCancelled
}
