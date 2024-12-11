import Foundation
import Combine

class OtaUpdateManager: OtaUpdateManagerProtocol {
    private let otaService: OtaServiceProtocol
    private let frikarConfigProvider: FrikarConfigProtocol
    private let fileTransferHandler: OtaFileTransferProtocol

    private var updateInfo: OtaUpdateInfo?

    init(otaService: OtaServiceProtocol,
         frikarConfigProvider: FrikarConfigProtocol,
         fileTransferHandler: OtaFileTransferProtocol
    ) {
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

        let otaUpdateFiles = try await withThrowingTaskGroup(of: (String, Data).self) { group in
            let firmwareFiles = resource.firmwareModules?.map(\.fileName).compactMap { $0 }
            firmwareFiles?.forEach { fileName in
                group.addTask {
                    try (fileName, await self.otaService.getFirmwareFile(fileName))
                }
            }

            let firmwareFilesData = try await group.reduce(into: [:]) { dictionary, result in
                dictionary[result.0] = result.1
            }

            return OtaUpdateFiles(
                firmwareFiles: firmwareFilesData.map { key, value in OtaFile(name: key, data: value) },
                audioFiles: []
            )
        }

        return otaUpdateFiles
    }

    func transferFile(_ otaFile: OtaFile) throws -> OtaTransferProgress {
        try fileTransferHandler.transferFile(otaFile)
    }

    func runUpgrade() {
        // TODO - error handling, status handling
        // fileTransferHandler.runUpgrade() // TODO - uncomment when ready for testing
    }
}

enum OtaUpdateError: Error {
    case frikarConfigFetchError
    case updateInfoMissing
    case downloadError
    case transferError
    case generalError
}
