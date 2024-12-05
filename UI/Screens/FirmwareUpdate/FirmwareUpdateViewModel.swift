import Foundation

class FirmwareUpdateViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let bleManager: BleManager

    init(
        coordinator: BaseCoordinator?,
        bleManager: BleManager
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager

        super.init()

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {

    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
