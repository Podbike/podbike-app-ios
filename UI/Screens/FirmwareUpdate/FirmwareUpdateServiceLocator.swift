import SwiftUI

class FirmwareUpdateServiceLocator {
    static let instance = FirmwareUpdateServiceLocator()

    func provideFirmwareUpdateView(coordinator: BaseCoordinator?) -> some View {
        let model = FirmwareUpdateViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance
        )
        return FirmwareUpdateView(viewModel: model)
    }
}
