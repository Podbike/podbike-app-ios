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
