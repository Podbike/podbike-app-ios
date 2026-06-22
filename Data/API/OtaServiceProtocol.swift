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

protocol OtaServiceProtocol {
    func isUpdateAvailable(for frikarConfig: FrikarConfig) async throws -> Bool
    func getOtaUpdateInfo(for frameNumber: String) async throws -> OtaUpdateInfo

    func getLicenseFile(_ fileName: String) async throws -> Data
    func getFirmwareFile(_ fileName: String) async throws -> Data
    func getAudioFile(_ fileName: String) async throws -> Data
}
