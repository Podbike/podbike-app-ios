import Combine
import Foundation
import SwiftUI

class DashboardViewModel: BaseViewModel {
    private weak var coordinator: DashboardCoordinatorViewModel?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences

    @Published var connectedDevice: BleDevice?

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
            .removeDuplicates(by: {d1, d2 in d1?.deviceId == d2?.deviceId})
            .sink { [weak self] connectedDevice in
                self?.isReconnectEnabled = true
                self?.connectedDevice = connectedDevice
                if (connectedDevice == nil) {
                    self?.reconnect()
                }
            }
            .store(in: &cancellables)
    }

    func reconnect() {
//        Task { @MainActor in
//            let count = coordinator?.routes.count
//            if !(coordinator?.routes.canGoBack() ?? true) {
//                coordinator?.showBleAutoConnectScreen()
//            }
//        }

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
