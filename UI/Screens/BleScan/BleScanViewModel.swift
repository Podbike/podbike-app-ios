import Combine
import Foundation
import SwiftUI

class BleScanViewModel: BaseViewModel {
    private weak var coordinator: BleScanCoordinatorViewModel?
    private let bleManager: BLEManager

    @Published var isScanning: Bool
    @Published var scannedDevices: [BLEDeviceProtocol]

    init(coordinator: BleScanCoordinatorViewModel, bleManager: BLEManager) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.isScanning = bleManager.isScanning.value
        self.scannedDevices = bleManager.scannedDevices.value

        super.init()

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        bleManager.isScanning
            .sink { [weak self] in self?.isScanning = $0 }
            .store(in: &cancellables)

        bleManager.scannedDevices
            .sink { [weak self] in self?.scannedDevices = $0 }
            .store(in: &cancellables)
    }

    func dismiss() {
        coordinator?.dismiss()
    }

    func startScan() {
        bleManager.startScan()
    }

    func stopScan() {
        bleManager.stopScan()
    }
}
