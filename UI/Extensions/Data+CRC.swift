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
