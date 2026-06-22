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

import Combine
import Foundation
import SwiftUI

class DashboardViewModel: BaseViewModel {
    private weak var coordinator: DashboardCoordinatorViewModel?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences
    private let tripMetrics: TripMetrics

    @Published var isBluetoothOn: Bool = true
    @Published var connectingDevice: BleDevice?
    @Published var connectedDevice: BleDevice?

    @Published var isBikeOn: Bool? {
        didSet {
            updateTripStartOffset()
        }
    }

    @Published var isRidingMode: Bool = false

    @Published var isShowingHelpInfo: Bool = false
    @Published var isHelpMode: Bool = false

    @Published var isSnowAlert: Bool = false
    @Published var isBrakeLight: Bool = false
    @Published var speedText: String = "0"
    @Published var batteryPercent: Int = 0
    @Published var rangeText: String = ""
    @Published var totalDistanceText: String = ""
    @Published var isLowBeam: Bool = false
    @Published var isHighBeam: Bool = false
    @Published var assistanceLevel: Int = 0
    @Published var cadenceLevel: Int = 0
    @Published var isLeftTurnIndicator: Bool = false
    @Published var isRightTurnIndicator: Bool = false
    @Published var isHazardIndicator: Bool = false

    @Published var isFirmwareUpdateInProgress: Bool = false
    @Published var showFirmwareUpdateCompleted: Bool = false
    @Published var showFirmwareUpdateFailed: Bool = false

    private var isReconnectEnabled = false
    private var dataCancellables = Set<AnyCancellable>()

    private var statisticsResetTimer: Timer?
    private var previouslyConnectedDevice: BleDevice?

    init(
        coordinator: DashboardCoordinatorViewModel,
        bleManager: BleManager,
        userPreferences: UserPreferences,
        tripMetrics: TripMetrics
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences
        self.tripMetrics = tripMetrics

        super.init()

        subscribeToPublishers()
    }

    private func resetData() {
        isBikeOn = nil
        isRidingMode = false
        isSnowAlert = false
        isBrakeLight = false
        speedText = "0"
        batteryPercent = 0
        rangeText = ""
        totalDistanceText = ""
        isLowBeam = false
        isHighBeam = false
        assistanceLevel = 0
        cadenceLevel = 0
        isLeftTurnIndicator = false
        isRightTurnIndicator = false
        isHazardIndicator = false
    }

    private func subscribeToPublishers() {
        bleManager.bleState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onBleStateUpdate($0) }
            .store(in: &cancellables)

        bleManager.connectingDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.connectingDevice = $0 }
            .store(in: &cancellables)

        bleManager.connectedDevice
            .receive(on: DispatchQueue.main)
            .removeDuplicates(by: { $0?.deviceId == $1?.deviceId })
            .sink { [weak self] in self?.onConnectedDeviceUpdate($0) }
            .store(in: &cancellables)

        userPreferences.objectWillChange
            .sink { [weak self] newUserPreferences in
                newUserPreferences
                if self?.connectedDevice != nil {
                    self?.subscribeForFrikarData()
                }
            }
            .store(in: &cancellables)
    }

    private func onBleStateUpdate(_ bleState: BleState) {
        isBluetoothOn = bleState == .ready
        if bleState == .ready && connectedDevice == nil {
            reconnect()
        }
    }

    private func onConnectedDeviceUpdate(_ connectedDevice: BleDevice?) {
        isReconnectEnabled = true
        self.connectedDevice = connectedDevice
        if let connectedDevice {
            onConnected(connectedDevice)
        } else {
            onDisconnected()
        }
    }

    private func onConnected(_ device: BleDevice) {
        statisticsResetTimer?.invalidate()
        statisticsResetTimer = nil

        if device.deviceId != previouslyConnectedDevice?.deviceId {
            tripMetrics.reset()
        }
        previouslyConnectedDevice = device

        subscribeForFrikarData()

        let currentDevice = userPreferences.storedDevices.first
        isFirmwareUpdateInProgress = currentDevice?.updateStarted ?? false
        if isFirmwareUpdateInProgress {
            validateFirmwareUpdate(expectedConfigHash: currentDevice?.updateConfigHash)
        }
    }

    private func onDisconnected() {
        resetData()
        reconnect()

        statisticsResetTimer?.invalidate()
        statisticsResetTimer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: false) { [weak self] _ in
            self?.tripMetrics.reset()
        }

        tripMetrics.tripInactivityStartTime = .now
    }

    private func subscribeForFrikarData() {
        dataCancellables.removeAll()

        bleManager.temperature.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTemperatureUpdate(temperatureCelsius: $0) }
            .store(in: &dataCancellables)

        bleManager.speed.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onSpeedUpdate(speedInKmph: $0) }
            .store(in: &dataCancellables)

        bleManager.batteryPercent.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onBatteryPercentUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.range.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onRangeUpdate(rangeInKm: $0) }
            .store(in: &dataCancellables)

        bleManager.totalDistance.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTotalDistanceUpdate(totalDistanceInMeters: $0) }
            .store(in: &dataCancellables)

        bleManager.lightsStatus.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onLightsStatusUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.assistanceLevel.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onAssistanceLevelUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.cadenceLevel.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onCadenceLevelUpdate($0) }
            .store(in: &dataCancellables)
    }

    private let snowAlertThresholdCelsius = 4

    var snowAlertThresholdText: String {
        let selectedTemperatureUnit = userPreferences.temperatureUnit
        let convertedTemperature = lround(selectedTemperatureUnit.converted(degreesCelsius: Double(snowAlertThresholdCelsius)))

        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        let temperatureUnit = formatter.string(from: selectedTemperatureUnit.unitType)

        return "\(convertedTemperature)\(temperatureUnit)"
    }

    private func onTemperatureUpdate(temperatureCelsius: Int?) {
        isSnowAlert = temperatureCelsius != nil ? temperatureCelsius! < snowAlertThresholdCelsius : false
    }

    var speedUnit: String {
        let selectedSpeedUnit = userPreferences.speedUnit
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        let speedUnit = formatter.string(from: selectedSpeedUnit.unitType).replacingOccurrences(of: "hr", with: "h")
        return speedUnit
    }

    var distanceUnit: String {
        let selectedDistanceUnit = userPreferences.distanceUnit
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        let distanceUnit = formatter.string(from: selectedDistanceUnit.unitType)
        return distanceUnit
    }

    private func onSpeedUpdate(speedInKmph: Int?) {
        let speedUnit = userPreferences.speedUnit
        let convertedSpeed = speedUnit.converted(kilometersPerHour: Double(speedInKmph ?? 0))
        speedText = String(lround(convertedSpeed))

        if let speedInKmph = speedInKmph {
            tripMetrics.maxTripSpeed = max(speedInKmph, tripMetrics.maxTripSpeed)

            if speedInKmph > 1 && tripMetrics.tripStartOffset == nil {
                tripMetrics.tripStartOffset = .now
            }
        }

#if !DEBUG
        updateRideMode(for: speedInKmph)
#endif
    }

    private func updateTripStartOffset() {
        if let tripInactivityStartTime = tripMetrics.tripInactivityStartTime,
           let tripStartOffset = tripMetrics.tripStartOffset,
           isBikeOn == true
        {
            let inactivityTime = tripInactivityStartTime.distance(to: .now)
            tripMetrics.tripStartOffset = tripStartOffset + inactivityTime
            tripMetrics.tripInactivityStartTime = nil
        }

        if isBikeOn == false && tripMetrics.tripInactivityStartTime == nil {
            tripMetrics.tripInactivityStartTime = .now
        }
    }

    private func updateRideMode(for speedInKmph: Int?) {
        let speedInKmph = speedInKmph ?? 0
        if speedInKmph >= 3 {
            isRidingMode = true
            Task {
                await coordinator?.goBackToRoot()
            }
        } else if speedInKmph == 0 {
            isRidingMode = false
        }
    }

    private func onBatteryPercentUpdate(_ batteryPercent: Int?) {
        self.batteryPercent = batteryPercent ?? 0
    }

    private func onRangeUpdate(rangeInKm: Int?) {
        guard let rangeInKm else {
            rangeText = ""
            return
        }

        var distanceUnit = userPreferences.distanceUnit
        if distanceUnit == .meters { distanceUnit = .kilometers }
        let convertedRange = distanceUnit.converted(kilometers: Double(rangeInKm))

        let measurement = Measurement(value: convertedRange.rounded(), unit: distanceUnit.unitType)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        rangeText = formatter.string(from: measurement)
    }

    private func onTotalDistanceUpdate(totalDistanceInMeters: Int?) {
        guard let totalDistanceInMeters else {
            totalDistanceText = ""
            return
        }

        // TODO: - temporary
        isBikeOn = totalDistanceInMeters > 0

        if tripMetrics.tripStartOffset != nil && tripMetrics.tripStartOdometer == nil {
            tripMetrics.tripStartOdometer = totalDistanceInMeters
        }

        let distanceUnit = userPreferences.distanceUnit
        let convertedTotalDistance = distanceUnit.converted(kilometers: Double(totalDistanceInMeters) / 1000)

        let measurement = Measurement(value: convertedTotalDistance, unit: distanceUnit.unitType)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        let decimalPlaces = distanceUnit == .meters ? 0 : 1
        formatter.numberFormatter.minimumFractionDigits = decimalPlaces
        formatter.numberFormatter.maximumFractionDigits = decimalPlaces
        totalDistanceText = formatter.string(from: measurement)
    }

    private func onLightsStatusUpdate(_ lightsStatus: LightsStatus?) {
        isLowBeam = lightsStatus?.lowBeam ?? false
        isHighBeam = lightsStatus?.highBeam ?? false
        isBrakeLight = lightsStatus?.brakeLight ?? false
        isLeftTurnIndicator = lightsStatus?.indicatorLeft ?? false
        isRightTurnIndicator = lightsStatus?.indicatorRight ?? false
        isHazardIndicator = isLeftTurnIndicator && isRightTurnIndicator
    }

    private func onAssistanceLevelUpdate(_ assistanceLevel: Int?) {
        self.assistanceLevel = assistanceLevel ?? 0

#if DEBUG
        // TODO: - temporary
        updateRideMode(for: (assistanceLevel ?? 0) / 20)
#endif
    }

    private func onCadenceLevelUpdate(_ cadenceLevel: Int?) {
        self.cadenceLevel = cadenceLevel ?? 0
    }

    private func validateFirmwareUpdate(expectedConfigHash: Int?) {
        if let expectedConfigHash = expectedConfigHash {
            Task { @MainActor in
                let deviceConfig = await bleManager.ymodemController.getFrikarConfig()

                if deviceConfig?.hashValue == expectedConfigHash {
                    showFirmwareUpdateCompleted = true
                } else {
                    showFirmwareUpdateFailed = true
                }
            }
        } else {
            showFirmwareUpdateFailed = true
        }

        isFirmwareUpdateInProgress = false
        userPreferences.setUpdateStartedFlag(false)
    }

    func reconnect() {
        let isShowingDashboard = !(coordinator?.canGoBack ?? false)
        if isReconnectEnabled, isShowingDashboard, let currentDevice = userPreferences.storedDevices.first {
            Task {
                try? await bleManager.connect(to: currentDevice)
            }
        }
    }

    func onConnectionCancelled() {
        bleManager.disconnect()
        Task {
            await coordinator?.showBleScanScreen()
        }
    }

    func showBleEnablePrompt() {
        bleManager.resetBleManager()
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }

    @MainActor
    func toggleHelp() {
        isShowingHelpInfo.toggle()
    }

    @MainActor
    func goToStatisticsScreen() {
        coordinator?.showStatisticsScreen()
    }

    @MainActor
    func goToSettingsScreen() {
        coordinator?.showSettingsScreen()
    }
}
