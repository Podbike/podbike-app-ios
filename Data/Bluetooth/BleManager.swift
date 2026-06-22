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
import CoreBluetooth
import Foundation
import os

class BleManager: NSObject {
    static let instance = BleManager()

    private lazy var centralManager: CBCentralManager! = initBleManager()
    private(set) lazy var ymodemController = YModemController(transport: self)

    var bleState = CurrentValueSubject<BleState, Never>(.unknown)

    let isScanning = CurrentValueSubject<Bool, Never>(false)
    let scannedDevices = CurrentValueSubject<[BleDevice], Never>([])

    lazy var connectingDevice = CurrentValueSubject<BleDevice?, Never>(nil)
    private var connectingPeripheral: CBPeripheral? {
        didSet {
            connectingDevice.value = connectingPeripheral
        }
    }

    private var connectionFailure: Error?

    lazy var connectedDevice = CurrentValueSubject<BleDevice?, Never>(nil)
    private var connectedPeripheral: CBPeripheral? {
        didSet {
            connectedDevice.value = connectedPeripheral
        }
    }

    private var characteristics = [CBCharacteristic]()

    // vvv FrikarDataProtocol properties - TODO: move to separate class
    private struct CharacteristicValue {
        var value: Data
        var characteristicUUID: CBUUID

        init(_ value: Data, for uuid: CBUUID) {
            self.value = value
            self.characteristicUUID = uuid
        }
    }

    private var characteristicValueUpdatedPublisher = PassthroughSubject<CharacteristicValue, Never>()
    // ^^^ FrikarDataProtocol properties

    let logger = os.Logger(subsystem: "com.podbike.app.Bluetooth", category: "BleManager")

    var cancellables = Set<AnyCancellable>()

    deinit {
        stopScan()
        logger.info("Scanning stopped")
    }

    func initBle() {
        if centralManager == nil {
            _ = initBleManager()
        }
    }

    private func initBleManager() -> CBCentralManager {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        return centralManager
    }

    private func characteristic(_ uuid: CBUUID) -> CBCharacteristic? {
        characteristics.first(where: { $0.uuid == uuid })
    }
}

// MARK: BleManagerProtocol

extension BleManager: BleManagerProtocol {
    func resetBleManager() {
        centralManager = nil
        _ = initBleManager()
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

        guard centralManager.state == .poweredOn else {
            logger.info("Cannot connect - Bluetooth is disabled")
            return
        }

        if let deviceUuid = UUID(uuidString: device.deviceId),
           let peripheral = centralManager.retrievePeripherals(withIdentifiers: [deviceUuid]).first
        {
            logger.info("Connecting to peripheral \(peripheral)")

            connectingPeripheral = peripheral
            connectionFailure = nil

            if #available(iOS 17.0, *) {
                centralManager.connect(
                    peripheral,
                    options: [CBConnectPeripheralOptionEnableAutoReconnect: true]
                )
            } else {
                centralManager.connect(peripheral, options: nil)
            }

            _ = try await connectingDevice
                .filter { $0 == nil }
                .eraseToAnyPublisher()
                .async()

            if connectedPeripheral == nil {
                throw BleManagerError.connectionFailed(error: connectionFailure)
            }
        }
    }

    func disconnect() {
        if let peripheral = connectedPeripheral ?? connectingPeripheral {
            logger.info("Close connection with BLE device: \(peripheral.deviceName)")
            centralManager.cancelPeripheralConnection(peripheral)
        }

        onDisconnected()
    }

    private func onDisconnected() {
        logger.info("onDisconnected")

        characteristicValueUpdatedPublisher.send(completion: .finished)
        characteristicValueUpdatedPublisher = PassthroughSubject<CharacteristicValue, Never>()

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
        disconnect()
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

        let advertisedName = advertisementData["kCBAdvDataLocalName"] as? String
        let peripheralName = peripheral.name
        if advertisedName != peripheralName {
            logger.error("Peripheral advertised name \"\(advertisedName ?? "")\" does not match the cached GAP name \"\(peripheralName ?? "")\"")
        }

        if !scannedDevices.value.contains(where: { $0.deviceId == peripheral.deviceId }) {
            let scannedDevice = ScannedDevice(peripheral, advertisedName: advertisedName)
            scannedDevices.value.append(scannedDevice)
        }
    }

    // Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.info("Peripheral connected, discovering services...")

        connectingPeripheral = peripheral

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
            connectionFailure = error
        }
    }

    // Disconnected
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.info("Perhiperal Disconnected \(peripheral.deviceName) \(error != nil ? "Error \(error!)" : "")")
        if peripheral == connectedPeripheral {
            onDisconnected()
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: Error?) {}
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

    // Data written
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error writting data: \"\(error.localizedDescription)\" to characteristic: \(characteristic.uuid)")
            disconnect()
            return
        }
    }

    // Data received
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            logger.error("Error reading data: \"\(error.localizedDescription)\" from characteristic: \(characteristic.uuid)")
            disconnect()
            return
        }

        if connectingPeripheral != nil && connectingPeripheral == peripheral {
            logger.info("Device connected, paired and ready: \(peripheral.deviceName)")
            connectedPeripheral = peripheral
            connectingPeripheral = nil
        }

        guard let characteristicData = characteristic.value else { return }

        let str = characteristicData.map { String(format: "0x%02x", $0) }.joined(separator: ", ")
        logger.info("Received \(characteristicData.count) bytes: \(str)")

        if let value = characteristic.value {
            characteristicValueUpdatedPublisher
                .send(CharacteristicValue(value, for: characteristic.uuid))
        }
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

    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        logger.warning("Podbike device name has changed to: \(peripheral.name ?? "")")
    }
}

// MARK: FrikarDataProtocol

extension BleManager: FrikarDataProtocol {
    private func observeCharacteristic<T>(_ uuid: CBUUID, dataMapper: @escaping (Data) -> T) -> CurrentValueSubject<T?, Never> {
        guard let characteristic = characteristic(uuid), let peripheral = connectedPeripheral else { return .init(nil) }

        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)

        let _value = CurrentValueSubject<T?, Never>(nil)
        characteristicValueUpdatedPublisher
            .filter { $0.characteristicUUID == uuid }
            .sink(
                receiveCompletion: { _value.send(completion: $0) },
                receiveValue: { _value.value = dataMapper($0.value) }
            )
            .store(in: &cancellables)
        return _value
    }

    var temperature: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.temperatureUUID) { PodbikeData($0).toTemperature }
    }

    var speed: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.speedUUID) { PodbikeData($0).toSpeed }
    }

    var averageSpeed: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.averageSpeedUUID) { PodbikeData($0).toAverageSpeed }
    }

    var batteryPercent: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.batteryUUID) { PodbikeData($0).toBatteryPercent }
    }

    var range: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.rangeUUID) { PodbikeData($0).toRange }
    }

    var totalDistance: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.totalDistanceUUID) { PodbikeData($0).toTotalDistance }
    }

    var lightsStatus: CurrentValueSubject<LightsStatus?, Never> {
        observeCharacteristic(PodbikeBleService.lightsStatusUUID) { PodbikeData($0).toLightsStatus }
    }

    var assistanceLevel: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.assistanceLevelUUID) { PodbikeData($0).toAssistanceLevel }
    }

    var cadenceLevel: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.cadenceLevelUUID) { PodbikeData($0).toCadenceLevel }
    }

    var generatedPower: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.generatedPowerUUID) { PodbikeData($0).toGeneratedPower }
    }

    var averageRpm: CurrentValueSubject<Int?, Never> {
        observeCharacteristic(PodbikeBleService.averageRpmUUID) { PodbikeData($0).toAverageRpm }
    }
}

// MARK: FrikarConfigProtocol

extension BleManager: FrikarConfigProtocol {
    func getFrikarConfig() async -> FrikarConfig? {
        await ymodemController.getFrikarConfig()
    }
}

// MARK: YModemTransportProtocol

extension BleManager: YModemTransportProtocol {
    var dataStream: AnyPublisher<Data, Never> {
        return observeYModemCharacteristic(PodbikeBleService.ftpDataUUID)
    }

    var controlStream: AnyPublisher<Data, Never> {
        return observeYModemCharacteristic(PodbikeBleService.ftpControlUUID)
    }

    func sendYModemData(_ data: Data, withResponse: Bool) {
        guard let characteristic = characteristic(PodbikeBleService.ftpDataUUID), let peripheral = connectedPeripheral else {
            logger.error("Cannot send YModem data.")
            return
        }
        peripheral.writeValue(
            data,
            for: characteristic,
            type: withResponse ? .withResponse : .withoutResponse
        )
        let str = data.map { String(format: "0x%02x", $0) }.joined(separator: ", ")
        logger.info("Sent \(data.count) bytes: \(str) via YModem")
    }

    func sendYModemControl(_ data: Data) {
        guard let characteristic = characteristic(PodbikeBleService.ftpControlUUID), let peripheral = connectedPeripheral else {
            logger.error("Cannot send YModem control data.")
            return
        }
        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )

        let str = data.map { String(format: "0x%02x", $0) }.joined(separator: ", ")
        logger.info("Sent \(data.count) control bytes: \(str) via YModem")
    }

    private func observeYModemCharacteristic(_ uuid: CBUUID) -> AnyPublisher<Data, Never> {
        guard let characteristic = characteristic(uuid), let peripheral = connectedPeripheral else { return Empty().eraseToAnyPublisher() }

        peripheral.setNotifyValue(true, for: characteristic)

        let _value = PassthroughSubject<Data, Never>()
        characteristicValueUpdatedPublisher
            .filter { $0.characteristicUUID == uuid }
            .sink(
                receiveCompletion: { _value.send(completion: $0) },
                receiveValue: { _value.send($0.value) }
            )
            .store(in: &cancellables)
        return _value.eraseToAnyPublisher()
    }
}
