import SwiftUI

class StatisticsServiceLocator {
    static let instance = StatisticsServiceLocator()

    func provideStatisticsView(coordinator: BaseCoordinator?) -> some View {
        let model = StatisticsViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance,
            userPreferences: UserPreferences.instance,
            tripMetrics: TripMetrics.instance
        )
        return StatisticsView(viewModel: model)
    }
}
