import Foundation

struct PodbikeData {
    private let data: Data

    init(_ data: Data) {
        self.data = data
    }

    private var intFromString: Int {
        let intString = String(decoding: data, as: UTF8.self)
            .trimmingCharacters(in: .controlCharacters)
            .trimmingCharacters(in: .whitespaces)
        let value = Int(intString) ?? 0
        return value
    }

    var toTemperature: Int {
        intFromString // Celsius
    }

    var toSpeed: Int {
        intFromString // kmph
    }

    var toBatteryPercent: Int {
        intFromString // %
    }

    var toRange: Int {
        intFromString // km
    }

    var toTotalDistance: Int {
        intFromString // meters
    }

    var toAssistanceLevel: Int {
        intFromString
    }

    var toCadenceLevel: Int {
        intFromString
    }

    var toLightsStatus: LightsStatus {
        LightsStatus(
            lowBeam: data.byte(0).asAsciiFlag, // TODO - confirm byte
            highBeam: data.byte(6).asAsciiFlag,
            rearLight: data.byte(5).asAsciiFlag, // TODO - confirm byte
            brakeLight: data.byte(4).asAsciiFlag, // TODO - confirm byte
            indicatorLeft: data.byte(3).asAsciiFlag,
            indicatorRight: data.byte(2).asAsciiFlag,
            reverseLight: data.byte(1).asAsciiFlag,
            runningLight: data.byte(7).asAsciiFlag // TODO - confirm byte
        )
    }
}

extension Data {
    func byte(_ index: Int) -> UInt8? {
        dropFirst(index).first
    }
}

extension UInt8? {
    var asAsciiFlag: Bool {
        let zeroAsciiCharacter = 0x30
        return (self ?? 0) > zeroAsciiCharacter
    }
}
