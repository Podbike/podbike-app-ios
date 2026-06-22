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

extension Data {
    func crc16ccitt(seed: UInt16 = 0x0000) -> Data {
        let ccittPolynominal: UInt16 = 0x1021
        var crc = seed
        for byte in self.bytes {
            crc ^= UInt16(byte) << 8
            for _ in 0 ..< 8 {
                crc = (crc & 0x8000) != 0 ? (crc << 1) ^ ccittPolynominal : crc << 1
            }
        }
        var bytes = crc.byteSwapped
        return Data(
            bytes: &bytes,
            count: MemoryLayout.size(ofValue: crc)
        )
    }
}
