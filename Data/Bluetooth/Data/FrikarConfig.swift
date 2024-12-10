struct FrikarConfig : Codable, Hashable {

    let productName: String?
    let releaseId: String?
    let productId: String?
    let frameNumber: String?
    let ecuModules: [EcuModule]?

    enum CodingKeys: String, CodingKey, Codable {
        case productName = "Product name"
        case releaseId = "ReleaseID"
        case productId = "ProductID"
        case frameNumber = "Frame number"
        case ecuModules = "ECU Modules"
    }
}

struct EcuModule : Codable, Hashable {

    let boardName: String?
    let boardId: String?
    let serialNumber: String?
    let boardPosition: String?
    let firmwareVersion: String?

    enum CodingKeys: String, CodingKey, Decodable {
        case boardName = "Board name"
        case boardId = "BoardID"
        case serialNumber = "Serial number"
        case boardPosition = "Board position"
        case firmwareVersion = "FWVersion"
    }
}
