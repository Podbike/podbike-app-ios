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
