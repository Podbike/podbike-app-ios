import Combine
import Foundation
import SwiftUI

class BleAutoConnectViewModel: BaseViewModel {
    private weak var coordinator: AppCoordinatorViewModel?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences

    @Published var bleState: BleState
    @Published var isScanning: Bool
    @Published var isConnecting: Bool
    @Published var autoConnectDevice: BleDevice?
    @Published var showConnectionFailed = false

    private let initTime = DispatchTime.now()

    enum Constants {
        static let minimumScreenDisplayInSeconds = 2.0
    }

    init(
        coordinator: AppCoordinatorViewModel?,
        bleManager: BleManager,
        userPreferences: UserPreferences
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences

        self.bleState = bleManager.bleState.value
        self.isScanning = bleManager.isScanning.value
        self.isConnecting = false
        self.autoConnectDevice = userPreferences.storedDevices.first

        super.init()

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        bleManager.initBle()

        bleManager.bleState
            .sink { [weak self] bleState in
                self?.bleState = bleState
                self?.startAutoConnect()
            }
            .store(in: &cancellables)

        bleManager.isScanning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.isScanning = $0 }
            .store(in: &cancellables)

        bleManager.scannedDevices
            .sink { [weak self] in
                self?.onDevicesFound($0)
            }
            .store(in: &cancellables)
    }

    private func onDevicesFound(_ devices: [BleDevice]) {
        if let foundDevice = devices.first(where: { $0.deviceId == autoConnectDevice?.deviceId }) {
            stopAutoConnect()
            isConnecting = true
            Task {
                do {
                    try await bleManager.connect(to: foundDevice)
                    userPreferences.storeDevice(foundDevice) // update device info if needed
                    await goToDashboardScreen()
                } catch {
                    await onConnectionError()
                }
            }
        }
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }

    func startAutoConnect() {
        bleManager.disconnect()
        if bleState == .ready {
            bleManager.startScan()
        }
    }

    func stopAutoConnect() {
        bleManager.stopScan()
        bleManager.disconnect()
        isConnecting = false
    }

    func showBleEnablePrompt() {
        bleManager.resetBleManager()
    }

    @MainActor
    func onConnectionError() {
        showConnectionFailed = true
        stopAutoConnect()
    }

    @MainActor
    func goToBleScanScreen() {
        bleManager.disconnect()
        coordinator?.showBleScanScreen()
    }

    @MainActor
    func goToDashboardScreen() {
        let screenDisplayTime = Double(DispatchTime.now().uptimeNanoseconds - initTime.uptimeNanoseconds) / 1_000_000_000
        let delayTime = Constants.minimumScreenDisplayInSeconds - screenDisplayTime

        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) { [weak self] in
            self?.coordinator?.dismiss()
        }
    }
}
