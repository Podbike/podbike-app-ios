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

/// Contents of the frikar.json file to be transferred to the board before other update files
struct FrikarTransferConfig: Codable, Hashable {
    let productName: String
    let releaseId: String
    let productId: String
    let supportedBoards: [SupportedBoard]
    let audioFiles: [AudioFile]

    enum CodingKeys: String, CodingKey {
        case productName = "Product name"
        case releaseId = "ReleaseID"
        case productId = "ProductID"
        case supportedBoards = "SupportedBoards"
        case audioFiles = "AudioFiles"
    }
}

struct SupportedBoard: Codable, Hashable {
    let boardName: String
    let boardId: String
    let serialNumber: String
    let firmwareVersion: String
    let fileName: String

    enum CodingKeys: String, CodingKey {
        case boardName = "Board name"
        case boardId = "BoardID"
        case serialNumber = "Serial number"
        case firmwareVersion = "FWVersion"
        case fileName = "Filename"
    }
}
