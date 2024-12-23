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
