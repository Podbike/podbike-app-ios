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
