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
