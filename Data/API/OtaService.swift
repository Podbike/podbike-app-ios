import Foundation

class OtaService: OtaServiceProtocol {
    private lazy var urlSession = URLSession(
        configuration: URLSessionConfiguration.default
    )

    private lazy var baseOtaUrl: URL =
        URL(string: Bundle.main.object(forInfoDictionaryKey: "OTA_BASE_URL") as! String)!

    func isUpdateAvailable(for frikarConfig: FrikarConfig) async throws -> Bool {
        let url = URL(string: "firmware_UpToDateCheck?returns=bit", relativeTo: baseOtaUrl)!
        let postBody = try JSONEncoder().encode(frikarConfig)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postBody

        let (data, _) = try await urlSession.data(for: request)

        let responseString = String(data: data, encoding: .utf8) ?? ""
        return Int(responseString) == 1
    }

    func getOtaUpdateInfo(for frameNumber: String) async throws -> OtaUpdateInfo {
        let url = URL(string: "firmware_update?frameNumber=\(frameNumber)", relativeTo: baseOtaUrl)!
        let (data, _) = try await urlSession.data(from: url)

        let responseString = String(data: data, encoding: .utf8) ?? ""
        let updateInfo = try JSONDecoder().decode(OtaUpdateInfo.self, from: Data(responseString.utf8))

        return updateInfo
    }

    func getLicenseFile(_ fileName: String) async throws -> Data {
        let url = URL(string: "licenses/\(fileName)", relativeTo: baseOtaUrl)!
        let (data, _) = try await urlSession.data(from: url)
        return data
    }

    func getFirmwareFile(_ fileName: String) async throws -> Data {
        let url = URL(string: "firmware/\(fileName)", relativeTo: baseOtaUrl)!
        let (data, _) = try await urlSession.data(from: url)
        return data
    }

    func getAudioFile(_ fileName: String) async throws -> Data {
        let url = URL(string: "audio/\(fileName)", relativeTo: baseOtaUrl)! //TODO - check path
        let (data, _) = try await urlSession.data(from: url)
        return data
    }
}
