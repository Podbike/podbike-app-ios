import Foundation

protocol OtaServiceProtocol {
    func isUpdateAvailable(for frikarConfig: FrikarConfig) async throws -> Bool
    func getOtaUpdateInfo(for frameNumber: String) async throws -> OtaUpdateInfo

    func getLicenseFile(_ fileName: String) async throws -> Data
    func getFirmwareFile(_ fileName: String) async throws -> Data
    func getAudioFile(_ fileName: String) async throws -> Data
}
