import SwiftUI

class BleAutoConnectServiceLocator {
    static let instance = BleAutoConnectServiceLocator()

    func provideBleAutoConnectView(coordinator: BleAutoConnectCoordinatorViewModel) -> some View {
        let model = BleAutoConnectViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance,
            userPreferences: UserPreferences()
        )
        return BleAutoConnectView(viewModel: model)
    }
}
