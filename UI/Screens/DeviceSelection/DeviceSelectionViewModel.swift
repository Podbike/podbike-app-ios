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
