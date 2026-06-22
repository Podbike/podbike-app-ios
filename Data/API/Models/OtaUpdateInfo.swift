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

struct OtaUpdateInfo: Decodable, Hashable {
    let resource: [OtaResource]
    let audioFiles: [String?]?

    enum CodingKeys: String, CodingKey, Decodable {
        case resource
        case audioFiles
    }
}

struct OtaResource: Decodable, Hashable {
    let id: Int?
    let productId: String?
    let releaseId: String?
    let licenseLink: String?
    let dateCreated: String?
    let dateModified: String?
    let firmwareModules: [FirmwareModule]?

    enum CodingKeys: String, CodingKey, Decodable {
        case id = "id"
        case productId = "product_id"
        case releaseId = "release_id"
        case licenseLink = "license_link"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case firmwareModules = "firmware_module_by_update_id"
    }
}

struct FirmwareModule: Decodable, Hashable {
    let id: Int?
    let updateId: Int?
    let fileIndexId: Int?
    let boardName: String?
    let serialNumber: Int?
    let firmwareVersion: String?
    let fileName: String?
    let dateCreated: String?
    let dateModified: String?

    enum CodingKeys: String, CodingKey, Decodable {
        case id
        case updateId = "update_id"
        case fileIndexId = "file_index_id"
        case boardName = "board_name"
        case serialNumber = "serial_number"
        case firmwareVersion = "firmware_version"
        case fileName = "file_name"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
}
