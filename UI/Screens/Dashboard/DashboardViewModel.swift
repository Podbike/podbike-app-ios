import Combine
import Foundation
import SwiftUI

class DashboardViewModel: BaseViewModel {
    private weak var coordinator: DashboardCoordinatorViewModel?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences

    // TODO - temporary
    @Published var connectedDevice: BleDevice?

    @Published var isRideMode: Bool = false
    @Published var speedText: String = "0"
    @Published var batteryPercent: Int = 0
    @Published var rangeText: String = ""
    @Published var tripDistanceText: String = ""
    @Published var highBeam: Bool = false

    private var isReconnectEnabled = false

    init(coordinator: DashboardCoordinatorViewModel, bleManager: BleManager, userPreferences: UserPreferences) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences

        super.init()

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        bleManager.connectedDevice
            .receive(on: DispatchQueue.main)
            .removeDuplicates(by: { $0?.deviceId == $1?.deviceId })
            .sink { [weak self] connectedDevice in
                self?.isReconnectEnabled = true
                self?.connectedDevice = connectedDevice
                if connectedDevice == nil {
                    self?.reconnect()
                } else {
                    self?.subscribeForFrikarData()
                }
            }
            .store(in: &cancellables)
    }

    private func subscribeForFrikarData() {
        bleManager.speed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onSpeedUpdate(speedInKmph: $0) }
            .store(in: &cancellables)

        bleManager.batteryPercent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onBatteryPercentUpdate($0) }
            .store(in: &cancellables)

        bleManager.range
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onRangeUpdate($0) }
            .store(in: &cancellables)

        bleManager.tripDistance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTripDistanceUpdate($0) }
            .store(in: &cancellables)

        bleManager.lightsStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onLightsStatusUpdate($0) }
            .store(in: &cancellables)
    }

    private func onSpeedUpdate(speedInKmph: Int) {
        let speedUnit = userPreferences.speedUnit
        let convertedSpeed = speedUnit.converted(kilometersPerHour: Double(speedInKmph))
        speedText = String(lround(convertedSpeed))

        updateRideMode(for: speedInKmph)
    }

    private func updateRideMode(for speedInKmph: Int) {
        if speedInKmph >= 3 {
            isRideMode = true
        }
        else if speedInKmph == 0 {
            isRideMode = false
        }
    }

    private func onBatteryPercentUpdate(_ batteryPercent: Int) {
        self.batteryPercent = batteryPercent
    }

    private func onRangeUpdate(_ range: Int) {
        let distanceUnit = userPreferences.distanceUnit
        let convertedRange = distanceUnit.converted(kilometers: Double(range))

        let measurement = Measurement(value: convertedRange.rounded(), unit: distanceUnit.unitType)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        rangeText = formatter.string(from: measurement)
    }

    private func onTripDistanceUpdate(_ tripDistance: Int) {
        let distanceUnit = userPreferences.distanceUnit
        let convertedTripDistance = distanceUnit.converted(kilometers: Double(tripDistance)/1000)

        let measurement = Measurement(value: convertedTripDistance, unit: distanceUnit.unitType)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        tripDistanceText = formatter.string(from: measurement)
    }

    private func onLightsStatusUpdate(_ lightsStatus: LightsStatus) {
        highBeam = lightsStatus.highBeam
    }

    func reconnect() {
        let isShowingDashboard = !(coordinator?.canGoBack ?? false)
        if isReconnectEnabled, isShowingDashboard, let currentDevice = userPreferences.storedDevices.first {
            Task {
                try? await bleManager.connect(to: currentDevice)
            }
        }
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }

    @MainActor
    func goToSettingsScreen() {
        coordinator?.showSettingsScreen()
    }

    @MainActor
    func goToDebugHomeScreen() {
        coordinator?.showDebugHomeScreen()
    }
}
