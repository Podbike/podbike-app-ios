import Combine
import CoreBluetooth
import Foundation
import os

class BLEManager: NSObject {
    static let instance = BLEManager()

    var isScanning = CurrentValueSubject<Bool, Never>(false)
    var scannedDevices = CurrentValueSubject<[BLEDeviceProtocol], Never>([])

    var bleDelegate: BLEManagerDelegate?
    lazy var connectedDevices: [BLEDeviceProtocol] = connectedPeripherals

    private var centralManager: CBCentralManager!

    private var connectedPeripherals: [CBPeripheral] = []

    private var bluetoothReady = false
    private var shouldCallPeripheralDisconnectCallback = true

    private let logger = os.Logger(subsystem: "com.podbike.app.Bluetooth", category: "BluetoothLEManager")

    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }

    deinit {
        stopScan()
        logger.info("Scanning stopped")
    }

    // Sends data to the peripheral.
    private func writeDataTo(peripheral: CBPeripheral, data: Data) {
        if let transferCharacteristic = peripheral.rxCharacteristic { // HCTCH_CBP
            printIfDebug("Write data to \(peripheral.deviceName)")

            let mtu = peripheral.maximumWriteValueLength(for: .withResponse)

            let bytesToCopy: size_t = min(mtu, data.count)

            var rawPacket = [UInt8](repeating: 0, count: bytesToCopy)
            data.copyBytes(to: &rawPacket, count: bytesToCopy)
            let packetData = Data(bytes: &rawPacket, count: bytesToCopy)

            let stringFromData = packetData.map { String(format: "0x%02x, ", $0) }.joined()
            logger.info("Writing \(bytesToCopy) bytes: \(String(describing: stringFromData))")

            peripheral.writeValue(packetData, for: transferCharacteristic, type: .withResponse)
        }
    }
}

// MARK: Support

extension BLEManager {
    private func addConnectedPeripheral(_ peripheral: CBPeripheral) {
        if getConnectedPeripheral(peripheral) == nil {
            connectedPeripherals.append(peripheral)
        }
    }

    private func getConnectedPeripheral(_ peripheral: CBPeripheral) -> CBPeripheral? {
        return connectedPeripherals.filter { peripheralF in peripheralF == peripheral }.first
    }

    @discardableResult private func removeConnectedPeripheral(_ peripheral: CBPeripheral) -> Bool {
        if let index = connectedPeripherals.firstIndex(of: peripheral) {
            connectedPeripherals.remove(at: index)
            return true
        } else {
            return false
        }
    }

    private func removeAllConnectedPeripherals() {
        connectedPeripherals.removeAll()
    }
}

// MARK: BLEManagerProtocol

extension BLEManager: BLEManagerProtocol {
    func isEnabled() -> Bool {
        return bluetoothReady
    }

    func sendDataTo(device: BLEDeviceProtocol, data: Data) throws {
        printIfDebug("Send Data To \(device.deviceName)")

        if let peripheral = device as? CBPeripheral,
           let peripheralConnected = getConnectedPeripheral(peripheral)
        {
            writeDataTo(peripheral: peripheralConnected, data: data)
        } else {
            printIfDebug("Error sendind Data To \(device.deviceName)")
            throw BLEManagerError.noPeripheral
        }
    }

    func startScan() {
        logger.info("Starting to scan.")
        scannedDevices.value = []
        centralManager.scanForPeripherals(
            withServices: nil // [PodbikeBLEService.serviceUUID]
        )
        isScanning.value = centralManager.isScanning
    }

    func stopScan() {
        logger.info("Stopping to scan.")
        centralManager.stopScan()
        isScanning.value = centralManager.isScanning
    }

    func connectTo(device: BLEDeviceProtocol) {
        // The peripheral, if connect, it's added in centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let peripheral = device as? CBPeripheral {
            logger.info("Connecting to peripheral \(peripheral)")
            addConnectedPeripheral(peripheral) // Here to maintain a reference to the device while try to connect, if not, sometimes lost the reference and finally doesn't establish a connection
            centralManager.connect(peripheral, options: nil)
        }
    }

    func disconnectDevice(_ device: BLEDeviceProtocol) {
        // Stops an erroneous or completed connection. Note, `didUpdateNotificationStateForCharacteristic`
        // cancels the connection if a subscriber exists.

        guard let peripheral = device as? CBPeripheral,
              let peripheralConnected = getConnectedPeripheral(peripheral)
        else { return }

        // Not interested in disconnection callback
        shouldCallPeripheralDisconnectCallback = false

        logger.info("Close connection with LE device: \(peripheral.deviceName)")

        // When a connection exists without a subscriber, only disconnect.
        if case .connected = peripheral.state { // Don't do anything if we're not connected
            for service in peripheral.services ?? [] as [CBService] {
                for characteristic in service.characteristics ?? [] as [CBCharacteristic] {
                    if characteristic.uuid == PodbikeBLEService.rxCharacteristicUUID && characteristic.isNotifying {
                        // It is notifying, so unsubscribe
                        peripheral.setNotifyValue(false, for: characteristic)
                    }
                }
            }
        }

        centralManager.cancelPeripheralConnection(peripheralConnected)
        removeConnectedPeripheral(peripheral)
    }

    func triggerPairing(device: BLEDeviceProtocol) throws {
        logger.info("Trigger pairing.")

        // TODO:
//        if let peripheral = device as? CBPeripheral,
//           let readCharacteristic = peripheral.txEncryptedCharacteristic
//        {
//            logger.info("Read characteristic")
//            peripheral.readValue(for: readCharacteristic)
//        } else {
//            printIfDebug("Error pairing to \(device.deviceName)")
//            throw BLEManagerError.noPeripheral
//        }
    }

    func disconnectAll() {
        logger.info("Close all LE connections")

        for peripheral in connectedPeripherals {
            disconnectDevice(peripheral)
        }
    }
}

// MARK: An extention to implement `CBCentralManagerDelegate` methods.

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothReady = false

        switch central.state {
        case .poweredOn:
            logger.info("CBManager is powered on")
            bluetoothReady = true
            handleCBOn()
        case .poweredOff:
            logger.error("CBManager is not powered on")
            handleCBOff()
            return
        case .resetting:
            logger.error("CBManager is resetting")
            return
        case .unauthorized:
            handleCBUnauthorized()
            return
        case .unknown:
            logger.error("CBManager state is unknown")
            return
        case .unsupported:
            logger.error("Bluetooth is not supported on this device")
            return
        @unknown default:
            logger.error("A previously unknown central manager state occurred")
            return
        }
    }

    func handleCBOn() {
        logger.info("Handle CB On")
        bleDelegate?.onChangedState(powered: true)
    }

    func handleCBOff() {
        logger.info("Handle CB Off")
        bleDelegate?.onChangedState(powered: false)
    }

    func handleCBUnauthorized() {
        switch CBManager.authorization {
        case .denied:
            // In your app, consider sending the user to Settings to change authorization.
            logger.error("The user denied Bluetooth access.")
        case .restricted:
            logger.error("Bluetooth is restricted")
        default:
            logger.error("Unexpected authorization")
        }
    }

    // Reacts to device discovery.
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber)
    {
        if peripheral.name == nil {
            return
        }

        // TODO - temporary
        if peripheral.name != "FRIKAR" {
            return
        }

        logger.info("Discovered \(String(describing: peripheral.name)) at\(RSSI.intValue)")

        if !scannedDevices.value.contains(where: { $0.deviceId == peripheral.deviceId }) {
            scannedDevices.value.append(peripheral)
        }

        bleDelegate?.onDiscoveredDevice(peripheral)
    }

    // Reacts to connection failure.
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.error("Failed to connect to \(peripheral). \(String(describing: error))")
        removeConnectedPeripheral(peripheral)
        disconnectDevice(peripheral)
    }

    // Discovers the services and characteristics to find the 'PodbikeBLEService'
    // characteristic after peripheral connection.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        self.addConnectedPeripheral(peripheral) //Already did it in func connectTo(device: BLEDeviceProtocol)
        logger.info("Peripheral Connected")

        // Interested in disconnection callback
        shouldCallPeripheralDisconnectCallback = true

        // Set the `CBPeripheral` delegate to receive callbacks for its services discovery.
        peripheral.delegate = self

        // Search only for services that match the service UUID.
        peripheral.discoverServices([PodbikeBLEService.serviceUUID])
    }

    // Cleans up the local copy of the peripheral after disconnection.
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.info("Perhiperal Disconnected \(peripheral.deviceName) Error \(error)")
        removeConnectedPeripheral(peripheral)

        // Provide disconnection callback only if interested
        if shouldCallPeripheralDisconnectCallback {
            bleDelegate?.onDisconnectedDevice(peripheral)
        }
    }
}

// MARK: An extention to implement `CBPeripheralDelegate` methods.

extension BLEManager: CBPeripheralDelegate {
    // Reacts to peripheral services invalidation.
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == PodbikeBLEService.serviceUUID {
            logger.error("Transfer service is invalidated - rediscover services")
            peripheral.discoverServices([PodbikeBLEService.serviceUUID])
        }
    }

    // Reacts to peripheral services discovery.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            logger.error("Error discovering services: \(error.localizedDescription) for peripheral: \(peripheral.deviceName))")
            disconnectDevice(peripheral)
            return
        }
        logger.info("discovered service. Now discovering characteristics")
        // Check the newly filled peripheral services array for more services.
        guard let peripheralServices = peripheral.services else { return }
        for service in peripheralServices {
            peripheral.discoverCharacteristics([PodbikeBLEService.rxCharacteristicUUID, PodbikeBLEService.txCharacteristicUUID], for: service)
        }
    }

    // Subscribes to a discovered characteristic, which lets the peripheral know we want the data it contains.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Deal with errors (if any).
        if let error = error {
            logger.error("Error discovering characteristics: \(error.localizedDescription) for peripheral: \(peripheral.deviceName)")
            disconnectDevice(peripheral)
            return
        }

        // Check the newly filled peripheral services array for more services.
        guard let serviceCharacteristics = service.characteristics else { return }

        for characteristic in serviceCharacteristics where characteristic.uuid == PodbikeBLEService.rxCharacteristicUUID {
            // Subscribe to the transfer service's `rxCharacteristic`.
            peripheral.rxCharacteristic = characteristic
            logger.info("discovered characteristic: \(characteristic)")
        }

        for characteristic in serviceCharacteristics where characteristic.uuid == PodbikeBLEService.txCharacteristicUUID {
            // Subscribe to the transfer service's `txCharacteristic`.
            peripheral.txCharacteristic = characteristic
            logger.info("discovered characteristic: \(characteristic)")
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    // Reacts to data arrival through the characteristic notification.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Check if the peripheral reported an error.
        if let error = error {
            logger.error("Error discovering characteristics:\(error.localizedDescription) for peripheral: \(peripheral.deviceName)")
            disconnectDevice(peripheral)
            return
        }
        guard let characteristicData = characteristic.value else { return }

        let str = characteristicData.map { String(format: "0x%02x, ", $0) }.joined()
        logger.info("Received \(characteristicData.count) bytes: \(str)")

        bleDelegate?.onDataReceived(characteristicData, device: peripheral)
    }

    // Reacts to the subscription status.
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Check if the peripheral reported an error.
        if let error = error {
            logger.error("Error changing notification state: \(error.localizedDescription)")
            return
        }

        if characteristic.isNotifying {
            // Indicates the notification began.
            logger.info("Notification began on \(characteristic)")
        } else {
            // Because the notification stopped, disconnect from the peripheral.
            logger.info("Notification stopped on \(characteristic). Disconnecting peripheral: \(peripheral.deviceName)")
            disconnectDevice(peripheral)
        }

        logger.debug("Finished configuring characteristics")
        bleDelegate?.onConnectedDevice(peripheral)
    }
}

private enum BLEManagerError: Error {
    case noPeripheral, noPairing
}

// MARK: An extention to CBPeripheral now adding BLEDeviceProtocol

extension CBPeripheral: BLEDeviceProtocol {
    var deviceId: String {
        return identifier.uuidString
    }

    var deviceName: String {
        return name ?? ""
    }
}

// MARK: An extention to CBPeripheral now adding Characteristics

extension CBPeripheral {
    private enum AssociatedKeys {
        static var rxCharacteristic: CBCharacteristic?
        static var txCharacteristic: CBCharacteristic?
    }

    var rxCharacteristic: CBCharacteristic? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rxCharacteristic) as? CBCharacteristic
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.rxCharacteristic,
                    newValue as CBCharacteristic?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }

    var txCharacteristic: CBCharacteristic? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.txCharacteristic) as? CBCharacteristic
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.txCharacteristic,
                    newValue as CBCharacteristic?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
