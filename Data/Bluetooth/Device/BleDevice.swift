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

struct StoredDevice: BleDevice, Codable {
    var deviceId: String
    var deviceName: String

    init(_ device: BleDevice) {
        self.deviceId = device.deviceId
        self.deviceName = device.deviceName
    }
}
