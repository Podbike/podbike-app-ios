import SwiftUI

class DeviceSelectionServiceLocator {
    static let instance = DeviceSelectionServiceLocator()

    func provideDeviceSelectionView(coordinator: DeviceSelectionCoordinatorViewModel?) -> some View {
        let model = DeviceSelectionViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance,
            userPreferences: UserPreferences()
        )
        return DeviceSelectionView(viewModel: model)
    }
}
