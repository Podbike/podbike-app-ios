import Foundation

protocol BLEManagerDelegate {
    func onChangedState(powered: Bool)
    func onDiscoveredDevice(_ device: any BLEDeviceProtocol)
    func onConnectedDevice(_ device: any BLEDeviceProtocol)
    func onDisconnectedDevice(_ device: any BLEDeviceProtocol)
    func onDataReceived(_ data: Data, device: any BLEDeviceProtocol)
}

