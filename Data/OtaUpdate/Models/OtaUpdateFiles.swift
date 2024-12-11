import Foundation

struct OtaUpdateFiles {
    let firmwareFiles: [OtaFile]
    let audioFiles: [OtaFile]
}

struct OtaFile {
    let name: String
    let data: Data
}
