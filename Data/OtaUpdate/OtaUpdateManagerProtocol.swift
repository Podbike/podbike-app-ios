protocol OtaUpdateManagerProtocol {
    func isUpdateAvailable() async throws -> Bool
    func getOtaUpdateLicense() async throws -> String
}
