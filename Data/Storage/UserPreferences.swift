import SwiftUI

class UserPreferences: ObservableObject {
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
        storedDevices.removeAll(where: { $0.deviceId == device.deviceId })
        storedDevices.insert(StoredDevice(device), at: 0)
    }
}
