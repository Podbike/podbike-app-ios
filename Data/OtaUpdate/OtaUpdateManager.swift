/*
 * Copyright (C) 2026 Phal AS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import Combine
import Foundation

class OtaUpdateManager: OtaUpdateManagerProtocol {
    private let otaService: OtaServiceProtocol
    private let frikarConfigProvider: FrikarConfigProtocol
    private let fileTransferHandler: OtaFileTransferProtocol
    private let userPreferences: UserPreferences

    private var frikarConfig: FrikarConfig?
    private var updateInfo: OtaUpdateInfo?

    init(otaService: OtaServiceProtocol,
         frikarConfigProvider: FrikarConfigProtocol,
         fileTransferHandler: OtaFileTransferProtocol,
         userPreferences: UserPreferences)
    {
        self.otaService = otaService
        self.frikarConfigProvider = frikarConfigProvider
        self.fileTransferHandler = fileTransferHandler
        self.userPreferences = userPreferences
    }

    func isUpdateAvailable() async throws -> Bool {
        frikarConfig = await frikarConfigProvider.getFrikarConfig()
        guard let frikarConfig = frikarConfig, let frameNumber = frikarConfig.frameNumber else {
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
            let fileNames = resource.firmwareModules?.map(\.fileName).compactMap { $0 } ?? []

            for fileName in fileNames {
                group.addTask {
                    let fileData = try await self.otaService.getFirmwareFile(fileName)
                    let fileType = OtaFileType(fromFileName: fileName)
                    return (fileType, fileName, fileData)
                }
            }

            let otaFiles = try await group.reduce(into: [OtaFile]()) { array, result in
                let otaFile = OtaFile(type: result.0, fileName: result.1, data: result.2)
                array.append(otaFile)
            }

            let frikarTransferConfig = try createFrikarTransferConfigFile(serverUpdateInfo: updateInfo)

            let sortedOtaFiles = fileNames
                .map { fileName in otaFiles.first(where: { $0.fileName == fileName }) }
                .compactMap { $0 }

            return OtaUpdateFiles(
                frikarTransferConfig: frikarTransferConfig,
                otaFiles: sortedOtaFiles
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
        guard let frikarConfig else { return }
        fileTransferHandler.runUpgrade()
        userPreferences.setUpdateStartedFlag(true, for: frikarConfig)
    }

    private func createFrikarTransferConfigFile(serverUpdateInfo: OtaUpdateInfo) throws -> OtaFile {
        guard let serverUpdateResource = serverUpdateInfo.resource.first,
              let serverFirmwareModules = serverUpdateResource.firmwareModules
        else { throw OtaUpdateError.frikarConfigFetchError }

        let supportedBoards = serverFirmwareModules
            .filter { $0.serialNumber != nil }
            .map { serverFirmwareModule in
                let boardName = String(
                    serverFirmwareModule.fileName!
                        .split(separator: ":").last?
                        .split(separator: ".").first
                        ?? ""
                )
                return SupportedBoard(
                    boardName: boardName,
                    boardId: serverFirmwareModule.boardName!,
                    serialNumber: String(serverFirmwareModule.serialNumber!),
                    firmwareVersion: serverFirmwareModule.firmwareVersion!,
                    fileName: serverFirmwareModule.fileName!
                )
            }

        let audioFiles = serverUpdateInfo.audioFiles?.compactMap {
            audioFile in AudioFile(filename: audioFile)
        } ?? []
        let frikarTransferConfig = FrikarTransferConfig(
            productName: "FRIKAR",
            releaseId: serverUpdateResource.releaseId!,
            productId: serverUpdateResource.productId!,
            supportedBoards: supportedBoards,
            audioFiles: audioFiles
        )

        let configData = try JSONEncoder().encode(frikarTransferConfig)
        
        return OtaFile(type: .frikarTransferConfig, fileName: frikarTransferConfigFileName, data: configData)
    }
}

enum OtaUpdateError: Error {
    case frikarConfigFetchError
    case updateInfoMissing
    case apiErrorStatus
    case downloadError
    case transferError
    case transferCancelled
}
