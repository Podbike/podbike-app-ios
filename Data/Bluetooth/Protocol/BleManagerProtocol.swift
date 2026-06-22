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

protocol BleManagerProtocol {
    func initBle()

    func resetBleManager()

    var bleState: CurrentValueSubject<BleState, Never> { get }

    var isScanning: CurrentValueSubject<Bool, Never> { get }
    var scannedDevices: CurrentValueSubject<[BleDevice], Never> { get }

    func startScan()
    func stopScan()

    func connect(to device: BleDevice) async throws
    var connectedDevice: CurrentValueSubject<BleDevice?, Never> { get }

    func disconnect()
}

enum BleState {
    case unknown
    case ready
    case bluetoothOff
    case permissionsRequired
}

enum BleManagerError: Error {
    case connectionFailed(error: Error?)
}
