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
}

extension DistanceUnit {
    static var systemDefault: DistanceUnit {
        Locale.current.usesMetricSystem ? .kilometers : .miles
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
