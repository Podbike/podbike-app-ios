import Foundation

struct OtaUpdateFiles {
    let firmwareFiles: [OtaFile]
    let audioFiles: [OtaFile]
}

enum OtaFileType {
    case firmware
    case audio
}

struct OtaFile {
    let type: OtaFileType
    let fileName: String
    let data: Data
}
