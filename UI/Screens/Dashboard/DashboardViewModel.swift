import Combine
import Foundation
import SwiftUI

class DashboardViewModel: BaseViewModel {
    private weak var coordinator: DashboardCoordinatorViewModel?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences

    @Published var isBluetoothOn: Bool = true
    @Published var connectingDevice: BleDevice?
    @Published var connectedDevice: BleDevice?

    @Published var isBikeOn: Bool = true
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

    init(coordinator: DashboardCoordinatorViewModel, bleManager: BleManager, userPreferences: UserPreferences) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences

        super.init()

        subscribeToPublishers()
    }

    private func resetData() {
        isBikeOn = true
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
            .sink { [weak self]  in self?.onBleStateUpdate($0) }
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
            .sink { [weak self] _ in
                if self?.connectedDevice != nil {
                    self?.subscribeForFrikarData()
                }
            }
            .store(in: &cancellables)
    }

    private func onBleStateUpdate(_ bleState: BleState) {
        self.isBluetoothOn = bleState == .ready
        if bleState == .ready && connectedDevice == nil {
            reconnect()
        }
    }

    private func onConnectedDeviceUpdate(_ connectedDevice: BleDevice?) {
        isReconnectEnabled = true
        self.connectedDevice = connectedDevice
        if connectedDevice == nil {
            onDisconnected()
        } else {
            onConnected()
        }
    }

    private func onConnected() {
        subscribeForFrikarData()
    }

    private func onDisconnected() {
        resetData()
        reconnect()
    }

    private func subscribeForFrikarData() {
        dataCancellables.removeAll()
        bleManager.temperature
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTemperatureUpdate(temperatureCelsius: $0) }
            .store(in: &dataCancellables)

        bleManager.speed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onSpeedUpdate(speedInKmph: $0) }
            .store(in: &dataCancellables)

        bleManager.batteryPercent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onBatteryPercentUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.range
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onRangeUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.totalDistance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTotalDistanceUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.lightsStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onLightsStatusUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.assistanceLevel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onAssistanceLevelUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.cadenceLevel
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

        // TODO: - re-enable
//        updateRideMode(for: speedInKmph)
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

    private func onRangeUpdate(_ range: Int?) {
        guard let range else {
            rangeText = ""
            return
        }

        var distanceUnit = userPreferences.distanceUnit
        if distanceUnit == .meters { distanceUnit = .kilometers }
        let convertedRange = distanceUnit.converted(kilometers: Double(range))

        let measurement = Measurement(value: convertedRange.rounded(), unit: distanceUnit.unitType)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        rangeText = formatter.string(from: measurement)
    }

    private func onTotalDistanceUpdate(_ totalDistance: Int?) {
        guard let totalDistance else {
            totalDistanceText = ""
            return
        }

        isBikeOn = totalDistance > 0 // TODO - temporary

        let distanceUnit = userPreferences.distanceUnit
        let convertedTotalDistance = distanceUnit.converted(kilometers: Double(totalDistance) / 1000)

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

        updateRideMode(for: (assistanceLevel ?? 0) / 20)
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
    func goToSettingsScreen() {
        coordinator?.showSettingsScreen()
    }

    @MainActor
    func goToDebugHomeScreen() {
        coordinator?.showDebugHomeScreen()
    }
}
