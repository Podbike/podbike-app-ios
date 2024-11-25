import Combine
import CoreBluetooth
import Foundation
import os

class BleManager: NSObject {
    static let instance = BleManager()

    private var centralManager: CBCentralManager!

    var bleState = CurrentValueSubject<BleState, Never>(.unknown)

    let isScanning = CurrentValueSubject<Bool, Never>(false)
    let scannedDevices = CurrentValueSubject<[BleDevice], Never>([])

    lazy var connectingDevice = CurrentValueSubject<BleDevice?, Never>(nil)
    private var connectingPeripheral: CBPeripheral? {
        didSet {
            connectingDevice.value = connectingPeripheral
        }
    }

    lazy var connectedDevice = CurrentValueSubject<BleDevice?, Never>(nil)
    private var connectedPeripheral: CBPeripheral? {
        didSet {
            connectedDevice.value = connectedPeripheral
        }
    }

    private var characteristics = [CBCharacteristic]()

    let logger = os.Logger(subsystem: "com.podbike.app.Bluetooth", category: "BluetoothLEManager")

    var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        initBleManager()
    }

    deinit {
        stopScan()
        logger.info("Scanning stopped")
    }

    private func initBleManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }

    private func characteristic(_ uuid: CBUUID) -> CBCharacteristic? {
        characteristics.first(where: { $0.uuid == uuid })
    }
}

// MARK: BleManagerProtocol

extension BleManager: BleManagerProtocol {
    func resetBleManager() {
        centralManager = nil
        initBleManager()
    }

    func startScan() {
        if centralManager.isScanning { return }

        logger.info("Starting to scan.")
        scannedDevices.value = []
        centralManager.scanForPeripherals(
            withServices: [PodbikeBleService.serviceUUID]
        )
        isScanning.value = centralManager.isScanning
    }

    func stopScan() {
        logger.info("Stopping to scan.")
        centralManager.stopScan()
        isScanning.value = centralManager.isScanning
    }

    func connect(to device: BleDevice) async throws {
        disconnect()

        // The peripheral, if connect, it's added in centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let deviceUuid = UUID(uuidString: device.deviceId),
           let peripheral = centralManager.retrievePeripherals(withIdentifiers: [deviceUuid]).first
        {
            logger.info("Connecting to peripheral \(peripheral)")

            connectingPeripheral = peripheral
            centralManager.connect(peripheral, options: nil)

            _ = try await connectingDevice
                .filter { $0 == nil }
                .eraseToAnyPublisher()
                .async()

            if connectedPeripheral == nil {
                throw BleManagerError.connectionFailed
            }
        }
    }

    func disconnect() {
        if let peripheral = connectedPeripheral ?? connectingPeripheral {
            logger.info("Close connection with BLE device: \(peripheral.deviceName)")
            centralManager.cancelPeripheralConnection(peripheral)
        }

        connectingPeripheral = nil
        connectedPeripheral = nil
    }
}

// MARK: CBCentralManagerDelegate

extension BleManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            logger.info("CBManager is powered on")
            handleBleOn()
        case .poweredOff:
            logger.error("CBManager is not powered on")
            handleBleOff()
        case .resetting:
            logger.error("CBManager is resetting")
        case .unauthorized:
            handlePermissionsRequired()
        case .unknown:
            logger.error("CBManager state is unknown")
        case .unsupported:
            logger.error("Bluetooth is not supported on this device")
        @unknown default:
            logger.error("An unknown central manager state occurred")
        }
    }

    func handleBleOn() {
        bleState.value = .ready
    }

    func handleBleOff() {
        bleState.value = .bluetoothOff
        isScanning.value = false
        scannedDevices.value = []
    }

    func handlePermissionsRequired() {
        switch CBManager.authorization {
        case .denied:
            logger.error("The user denied Bluetooth access.")
        case .restricted:
            logger.error("Bluetooth is restricted")
        default:
            logger.error("Unexpected authorization")
        }
        bleState.value = .permissionsRequired
    }

    // Device discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripheral.name == nil {
            return
        }

        logger.info("Discovered \"\(peripheral.deviceName)\" at \(RSSI.intValue)dBm")

        if !scannedDevices.value.contains(where: { $0.deviceId == peripheral.deviceId }) {
            scannedDevices.value.append(peripheral)
        }
    }

    // Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Peripheral connected, discovering services...")

        // Discovers the services and characteristics to find the 'PodbikeBLEService'
        // characteristic after peripheral connection.
        peripheral.delegate = self
        peripheral.discoverServices([PodbikeBleService.serviceUUID])
    }

    // Connection failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.error("Failed to connect to \(peripheral). \(String(describing: error))")
        if peripheral == connectingPeripheral {
            connectingPeripheral = nil
        }
    }

    // Disconnected
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.info("Perhiperal Disconnected \(peripheral.deviceName) Error \(error)")
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
    }
}

// MARK: CBPeripheralDelegate

extension BleManager: CBPeripheralDelegate {
    // Services discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            logger.error("Error discovering services: \(error.localizedDescription) for peripheral: \(peripheral.deviceName))")
            disconnect()
            return
        }

        logger.info("Discovered Podbike BLE service. Now discovering characteristics...")
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // Characteristics discovered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            logger.error("Error discovering characteristics: \(error.localizedDescription) for peripheral: \(peripheral.deviceName)")
            disconnect()
            return
        }

        guard let characteristics = service.characteristics, !characteristics.isEmpty else {
            logger.error("Empty characteristics array for peripheral: \(peripheral.deviceName)")
            disconnect()
            return
        }

        self.characteristics = characteristics

        logger.info("Discovered characteristics(\(characteristics.count)) for peripheral: \(peripheral.deviceName)")

        // Perform test data read to wait for successful pairing and ensured connectivity
        guard let watchdogCharacteristic = characteristic(PodbikeBleService.connectionWatchdog) else {
            disconnect()
            return
        }
        peripheral.readValue(for: watchdogCharacteristic)
    }

    // Data received
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error discovering characteristics:\(error.localizedDescription) for peripheral: \(peripheral.deviceName)")
            disconnect()
            return
        }

        if connectingPeripheral != nil && connectingPeripheral == peripheral {
            logger.info("Device connected, paired and ready: \(peripheral.deviceName)")
            connectedPeripheral = peripheral
            connectingPeripheral = nil
        }

        guard let characteristicData = characteristic.value else { return }

        let str = characteristicData.map { String(format: "0x%02x, ", $0) }.joined()
        logger.info("Received \(characteristicData.count) bytes: \(str)")
    }

    // Notifications state changed
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error changing notification state: \(error.localizedDescription)")
            return
        }
    }

    // Services invalidated
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == PodbikeBleService.serviceUUID {
            logger.error("Podbike service invalidated - running re-discovery")
            peripheral.discoverServices([PodbikeBleService.serviceUUID])
        }
    }
}
