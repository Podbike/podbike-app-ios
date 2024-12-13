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

    @Published var isIceWarning: Bool = false
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
        isIceWarning = false
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

    private func onTemperatureUpdate(temperatureCelsius: Int?) {
        isIceWarning = temperatureCelsius != nil ? temperatureCelsius! < 4 : false
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
        formatter.numberFormatter.minimumFractionDigits = 1
        formatter.numberFormatter.maximumFractionDigits = 1
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
    func goToDebugHomeScreen() {
        coordinator?.showDebugHomeScreen()
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
