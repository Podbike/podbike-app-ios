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
