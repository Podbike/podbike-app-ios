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
#if DEBUG
        static let minimumScreenDisplayInSeconds = 0.0
#else
        static let minimumScreenDisplayInSeconds = 2.0
#endif
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
