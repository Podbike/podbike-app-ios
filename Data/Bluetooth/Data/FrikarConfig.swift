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

/// Contents of JSON config file as read from the board and sent to the OTA server
struct FrikarConfig: Codable, Hashable {
    let productName: String?
    let releaseId: String?
    let productId: String?
    let frameNumber: String?
    let ecuModules: [EcuModule]?
    let audioFiles: [AudioFile]?

    enum CodingKeys: String, CodingKey {
        case productName = "Product name"
        case releaseId = "ReleaseID"
        case productId = "ProductID"
        case frameNumber = "Frame number"
        case ecuModules = "ECU Modules"
        case audioFiles = "AudioFiles"
    }
}

struct EcuModule: Codable, Hashable {
    let boardName: String?
    let boardId: String?
    let serialNumber: String?
    let boardPosition: String?
    let firmwareVersion: String?

    enum CodingKeys: String, CodingKey {
        case boardName = "Board name"
        case boardId = "BoardID"
        case serialNumber = "Serial number"
        case boardPosition = "Board position"
        case firmwareVersion = "FWVersion"
    }
}

struct AudioFile: Codable, Hashable {
    let filename: String?

    enum CodingKeys: String, CodingKey {
        case filename = "Filename"
    }
}
