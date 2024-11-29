import SwiftUI

class DashboardServiceLocator {
    static let instance = DashboardServiceLocator()

    func provideDashboardView(coordinator: DashboardCoordinatorViewModel) -> some View {
        let model = DashboardViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance,
            userPreferences: UserPreferences.instance
        )
        return DashboardView(viewModel: model)
    }
}
