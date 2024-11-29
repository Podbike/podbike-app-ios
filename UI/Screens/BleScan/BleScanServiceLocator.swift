import SwiftUI

class BleScanServiceLocator {
    static let instance = BleScanServiceLocator()

    func provideBleScanView(coordinator: BaseCoordinator?) -> some View {
        let model = BleScanViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance,
            userPreferences: UserPreferences.instance
        )
        return BleScanView(viewModel: model)
    }
}
