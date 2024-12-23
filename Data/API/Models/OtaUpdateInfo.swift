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
