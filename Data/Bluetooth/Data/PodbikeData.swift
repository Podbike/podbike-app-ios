import Foundation

struct PodbikeData {
    private let data: Data

    init(_ data: Data) {
        self.data = data
    }

    private var intFromSting: Int {
        let intString = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespaces)
        let value = Int(intString) ?? 0
        return value // kmph
    }

    var toSpeed: Int {
        intFromSting // kmph
    }

    var toBatteryPercent: Int {
        intFromSting // %
    }

    var toRange: Int {
        intFromSting // km
    }

    var toTripDistance: Int {
        intFromSting // meters
    }

    var toLightsStatus: LightsStatus {


        return LightsStatus(
            lowBeam: data.byte(0).asFlag,
            highBeam: data.byte(1).asFlag,
            rearLight: data.byte(2).asFlag,
            brakeLight: data.byte(3).asFlag,
            indicatorLeft: data.byte(4).asFlag,
            indicatorRight: data.byte(5).asFlag,
            reverseLight: data.byte(6).asFlag,
            runningLight: data.byte(7).asFlag
        )
    }
}

extension Data {
    func byte(_ index: Int) -> UInt8? {
        dropFirst(index).first
    }
}

extension UInt8? {
    var asFlag: Bool {
        (self ?? 0) != 0
    }
}
