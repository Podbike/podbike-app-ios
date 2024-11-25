import Combine
import Foundation
import SwiftUI

class DeviceSelectionViewModel: BaseViewModel {
    private weak var coordinator: DeviceSelectionCoordinatorViewModel?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences

    @Published var storedDevices: [StoredDevice]
    @Published var showConnectionFailed = false

    init(coordinator: DeviceSelectionCoordinatorViewModel?, bleManager: BleManager, userPreferences: UserPreferences) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences
        self.storedDevices = userPreferences.storedDevices

        super.init()
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }


    func connect(to device: BleDevice) async {
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
    func goToBleScanScreen() {
        coordinator?.showBleScanScreen()
    }
}
