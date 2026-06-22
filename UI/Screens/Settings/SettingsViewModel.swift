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
import SwiftUI

class SettingsViewModel: BaseViewModel {
    private weak var coordinator: SettingsCoordinatorViewModel?
    private let userPreferences: UserPreferences

    @Published var speedUnit: SpeedUnit {
        didSet {
            userPreferences.speedUnit = speedUnit
        }
    }

    @Published var distanceUnit: DistanceUnit {
        didSet {
            userPreferences.distanceUnit = distanceUnit
        }
    }

    @Published var temperatureUnit: TemperatureUnit {
        didSet {
            userPreferences.temperatureUnit = temperatureUnit
        }
    }

    init(coordinator: SettingsCoordinatorViewModel, userPreferences: UserPreferences) {
        self.coordinator = coordinator
        self.userPreferences = userPreferences

        speedUnit = userPreferences.speedUnit
        distanceUnit = userPreferences.distanceUnit
        temperatureUnit = userPreferences.temperatureUnit
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }

    func onLanguageTapped() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    @MainActor
    func onDevicesTapped() {
        coordinator?.showDeviceSelection()
    }

    @MainActor
    func onFirmwareUpdateTapped() {
        coordinator?.showFirmwareUpdate()
    }

    @MainActor
    func onFrikarInfoTapped() {
        coordinator?.showFrikarInfo()
    }

    @MainActor
    func onPoliciesTapped() {
        coordinator?.showPolicies()
    }
}

extension SpeedUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .kilometersPerHour: return String(localized: "SettingsSpeedKmph")
        case .milesPerHour: return String(localized: "SettingsSpeedMiph")
        case .metersPerSecond: return String(localized: "SettingsSpeedMps")
        }
    }
}

extension DistanceUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .kilometers: return String(localized: "SettingsDistanceKm")
        case .miles: return String(localized: "SettingsDistanceMi")
        case .meters: return String(localized: "SettingsDistanceM")
        }
    }
}

extension TemperatureUnit: CustomStringConvertible {
    var description: String {
        switch self {
        case .celsius: return String(localized: "SettingsTemperatureC")
        case .fahrenheit: return String(localized: "SettingsTemperatureF")
        }
    }
}
