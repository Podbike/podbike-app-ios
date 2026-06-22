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

import SwiftUI

class UserPreferences: ObservableObject {
    static let instance = UserPreferences()
    private init() {}

    @AppStorage("idTutorialShown")
    var isTutorialShown: Bool = false

    @AppStorage("speedUnit")
    var speedUnit: SpeedUnit = .systemDefault

    @AppStorage("distanceUnit")
    var distanceUnit: DistanceUnit = .systemDefault

    @AppStorage("temperatureUnit")
    var temperatureUnit: TemperatureUnit = .systemDefault

    @AppStorage("storedDevices")
    var storedDevices: [StoredDevice] = []
}

extension UserPreferences {
    func storeDevice(_ device: BleDevice) {
        let oldDeviceEntry = storedDevices.first(where: { $0.deviceId == device.deviceId })
        var newDeviceEntry = device as? StoredDevice
        if newDeviceEntry == nil {
            newDeviceEntry = StoredDevice(device)
            newDeviceEntry?.updateStarted = oldDeviceEntry?.updateStarted
            newDeviceEntry?.updateConfigHash = oldDeviceEntry?.updateConfigHash
        }

        var newDevices = storedDevices
        newDevices.removeAll(where: { $0.deviceId == device.deviceId })
        newDevices.insert(newDeviceEntry!, at: 0)
        storedDevices = newDevices
    }

    func setUpdateStartedFlag(_ updateStarted: Bool, for frikarConfig: FrikarConfig? = nil) {
        if var currentDevice = storedDevices.first {
            currentDevice.updateStarted = updateStarted
            currentDevice.updateConfigHash = frikarConfig.hashValue
            storeDevice(currentDevice)
        }
    }
}
