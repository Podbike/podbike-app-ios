import Foundation

class OtaUpdateManager: OtaUpdateManagerProtocol {
    private let otaService: OtaServiceProtocol
    private let frikarConfigProvider: FrikarConfigProtocol

    private var updateInfo: OtaUpdateInfo?

    init(otaService: OtaServiceProtocol, frikarConfigProvider: FrikarConfigProtocol) {
        self.otaService = otaService
        self.frikarConfigProvider = frikarConfigProvider
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
        guard let updateInfo = self.updateInfo, let info = updateInfo.resource.first, let lisenseLink = info.licenseLink else {
            throw OtaUpdateError.updateInfoMissing
        }

        let licenseFile = try await otaService.getLicenseFile(lisenseLink)
        let licenseText = String(data: licenseFile, encoding: .utf8) ?? ""

        return licenseText
    }
}

enum OtaUpdateError: Error {
    case frikarConfigFetchError
    case updateInfoMissing
    case generalError
}
