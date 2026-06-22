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

import CoreBluetooth

protocol BleDevice {
    var deviceId: String { get }
    var deviceName: String { get }
}

extension CBPeripheral: BleDevice {
    var deviceId: String {
        return identifier.uuidString
    }

    var deviceName: String {
        return name ?? ""
    }
}

struct ScannedDevice: BleDevice {
    let peripheral: CBPeripheral
    let advertisedName: String?

    init(_ peripheral: CBPeripheral, advertisedName: String?) {
        self.peripheral = peripheral
        self.advertisedName = advertisedName
    }

    var deviceId: String {
        peripheral.deviceId
    }

    var deviceName: String {
        return advertisedName ?? peripheral.deviceName
    }
}

struct StoredDevice: BleDevice, Codable {
    let deviceId: String
    let deviceName: String
    var updateStarted: Bool?
    var updateConfigHash: Int?

    init(_ device: BleDevice) {
        self.deviceId = device.deviceId
        self.deviceName = device.deviceName
        self.updateStarted = false
    }
}
