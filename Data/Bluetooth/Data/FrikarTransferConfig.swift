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
