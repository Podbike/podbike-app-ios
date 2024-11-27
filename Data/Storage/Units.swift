import Foundation

enum SpeedUnit: String {
    case kilometersPerHour = "km/h"
    case milesPerHour = "mph"
    case metersPerSecond = "m/s"
}

enum DistanceUnit: String {
    case kilometers = "km"
    case miles = "mi"
    case meters = "m"
}

enum TemperatureUnit: String {
    case celsius = "C"
    case fahrenheit = "F"
}

extension SpeedUnit {
    static var systemDefault: SpeedUnit {
        Locale.current.usesMetricSystem ? .kilometersPerHour : .milesPerHour
    }

    var unitType: UnitSpeed {
        switch self {
        case .kilometersPerHour: return UnitSpeed.kilometersPerHour
        case .milesPerHour: return UnitSpeed.milesPerHour
        case .metersPerSecond: return UnitSpeed.metersPerSecond
        }
    }

    func converted(kilometersPerHour: Double) -> Double {
        Measurement(value: kilometersPerHour, unit: UnitSpeed.kilometersPerHour)
            .converted(to: self.unitType)
            .value
    }
}

extension DistanceUnit {
    static var systemDefault: DistanceUnit {
        Locale.current.usesMetricSystem ? .kilometers : .miles
    }

    var unitType: UnitLength {
        switch self {
        case .kilometers: return UnitLength.kilometers
        case .miles: return UnitLength.miles
        case .meters: return UnitLength.meters
        }
    }

    func converted(kilometers: Double) -> Double {
        Measurement(value: kilometers, unit: UnitLength.kilometers)
            .converted(to: self.unitType)
            .value
    }
}

extension TemperatureUnit {
    static var systemDefault: TemperatureUnit {
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.unitStyle = .medium
        let formatted = formatter.string(from: .init(value: 0, unit: UnitTemperature.celsius))
        let symbol = String(formatted.suffix(2))
        switch symbol {
        case UnitTemperature.celsius.symbol:
            return .celsius
        case UnitTemperature.fahrenheit.symbol:
            return .fahrenheit
        default:
            return .celsius
        }
    }
}
