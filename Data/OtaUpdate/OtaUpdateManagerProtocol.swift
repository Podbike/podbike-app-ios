protocol OtaUpdateManagerProtocol {
    func isUpdateAvailable() async throws -> Bool
    func getOtaUpdateLicense() async throws -> String
    func downloadOtaUpdateFiles() async throws -> OtaUpdateFiles
    func transferFile(_ otaFile: OtaFile) throws -> OtaTransferProgress
    func runUpgrade()
}
