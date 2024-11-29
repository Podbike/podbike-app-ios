import SwiftUI

class BleAutoConnectServiceLocator {
    static let instance = BleAutoConnectServiceLocator()

    func provideBleAutoConnectView(coordinator: AppCoordinatorViewModel?) -> some View {
        let model = BleAutoConnectViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance,
            userPreferences: UserPreferences.instance
        )
        return BleAutoConnectView(viewModel: model)
    }
}
