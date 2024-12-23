import Foundation

let frikarTransferConfigFileName = "frikar.json"

struct OtaUpdateFiles {
    let frikarTransferConfig: OtaFile
    let otaFiles: [OtaFile]
}

enum OtaFileType {
    case frikarTransferConfig /// frikar.json
    case firmware
    case audio

    init(fromFileName fileName: String) {
        if fileName.hasSuffix(".wav") { self = .audio }
        else if fileName == frikarTransferConfigFileName { self = .frikarTransferConfig }
        else { self = .firmware }
    }
}

struct OtaFile {
    let type: OtaFileType
    let fileName: String
    let data: Data
}
