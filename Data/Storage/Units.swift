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

    var unitType: UnitTemperature {
        switch self {
        case .celsius: return UnitTemperature.celsius
        case .fahrenheit: return UnitTemperature.fahrenheit
        }
    }

    func converted(degreesCelsius: Double) -> Double {
        Measurement(value: degreesCelsius, unit: UnitTemperature.celsius)
            .converted(to: self.unitType)
            .value
    }
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
