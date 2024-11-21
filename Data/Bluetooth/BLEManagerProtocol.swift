import Combine
import Foundation

protocol BLEManagerProtocol {
    func isEnabled() -> Bool

    var isScanning: CurrentValueSubject<Bool, Never> { get }
    var scannedDevices: CurrentValueSubject<[BLEDeviceProtocol], Never> { get }

    func startScan()
    func stopScan()

    func connectTo(device: BLEDeviceProtocol)
    func sendDataTo(device: BLEDeviceProtocol, data: Data) throws
    func triggerPairing(device: BLEDeviceProtocol) throws
    func disconnectDevice(_ device: BLEDeviceProtocol)
    func disconnectAll()

    var bleDelegate: BLEManagerDelegate? { get set }
    var connectedDevices: [BLEDeviceProtocol] { get }
}
