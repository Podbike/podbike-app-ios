import Combine
import Foundation
import SwiftUI

class BleScanViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences

    @Published var bleState: BleState
    @Published var isScanning: Bool
    @Published var scannedDevices: [BleDevice]

    @Published var showNavigationBar: Bool
    @Published var showConnectionFailed = false

    init(coordinator: BaseCoordinator?, bleManager: BleManager, userPreferences: UserPreferences) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences

        self.bleState = bleManager.bleState.value
        self.isScanning = bleManager.isScanning.value
        self.scannedDevices = bleManager.scannedDevices.value

        self.showNavigationBar = coordinator?.canGoBack ?? false

        super.init()

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        bleManager.initBle()

        bleManager.bleState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bleState in
                self?.bleState = bleState
                if bleState == .ready {
                    self?.startScan()
                }
            }
            .store(in: &cancellables)

        bleManager.isScanning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.isScanning = $0 }
            .store(in: &cancellables)

        bleManager.scannedDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.scannedDevices = $0 }
            .store(in: &cancellables)
    }

    @MainActor
    func dismiss() {
        stopScan()
        coordinator?.dismiss()
    }

    func startScan() {
        bleManager.disconnect()
        bleManager.startScan()
    }

    func stopScan() {
        bleManager.stopScan()
    }

    func connect(to device: BleDevice) async {
        stopScan()
        do {
            try await bleManager.connect(to: device)
            await onConnected(to: device)
        } catch {
            await showConnectionError()
        }
    }

    @MainActor
    private func onConnected(to device: BleDevice) {
        userPreferences.storeDevice(device)
        coordinator?.goBackToRoot()
    }

    @MainActor
    func showConnectionError() {
        showConnectionFailed = true
    }

    @MainActor
    func openAppSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    func showBleEnablePrompt() {
        bleManager.resetBleManager()
    }
}
