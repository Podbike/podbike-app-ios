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
        guard let updateStatus = Int(responseString) else { throw URLError(.cannotParseResponse) }
        guard updateStatus < 2 else { throw OtaUpdateError.apiErrorStatus }
        let isUpdateAvailable = updateStatus == 0
        return isUpdateAvailable
    }

    func getOtaUpdateInfo(for frameNumber: String) async throws -> OtaUpdateInfo {
        let url = URL(string: "firmware_update?frameNumber=\(frameNumber)", relativeTo: baseOtaUrl)!
        let (data, _) = try await urlSession.data(from: url)

        let responseString = String(data: data, encoding: .utf8) ?? ""
        let updateInfo = try JSONDecoder().decode(OtaUpdateInfo.self, from: Data(responseString.utf8))

        return updateInfo
    }

    private func getFile(_ fileName: String) async throws -> Data {
        let url = URL(string: fileName, relativeTo: baseOtaUrl)!
        let (data, response) = try await urlSession.data(from: url)
        if let httpUrlResponse = response as? HTTPURLResponse {
            if httpUrlResponse.statusCode >= 400 || data.isEmpty {
                throw URLError(.badServerResponse)
            }
            let contentType = httpUrlResponse.allHeaderFields["Content-Type"] as? String
            if contentType?.contains("text/html") == true {
                throw URLError(.cannotParseResponse)
            }
        }
        return data
    }

    func getLicenseFile(_ fileName: String) async throws -> Data {
        try await getFile("licenses/\(fileName)")
    }

    func getFirmwareFile(_ fileName: String) async throws -> Data {
        try await getFile("firmware/\(fileName)")
    }

    func getAudioFile(_ fileName: String) async throws -> Data {
        try await getFile("firmware/\(fileName)")
    }
}
