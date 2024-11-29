import Foundation

class CoordinatorServiceLocator {
    static let instance = CoordinatorServiceLocator()

    func provideAppCoordinator() -> AppCoordinator {
        AppCoordinator(
            viewModel: AppCoordinatorViewModel(
                bleManager: BleManager.instance,
                userPreferences: UserPreferences.instance
            )
        )
    }

    func provideDebugHomeCoordinator(parentCoordinator: BaseCoordinator) -> HomeCoordinator {
        HomeCoordinator(viewModel: HomeCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideSettingsCoordinator(parentCoordinator: BaseCoordinator) -> SettingsCoordinator {
        SettingsCoordinator(viewModel: SettingsCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideDeviceSelectionCoordinator(parentCoordinator: BaseCoordinator) -> DeviceSelectionCoordinator {
        DeviceSelectionCoordinator(viewModel: DeviceSelectionCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideDashboardCoordinator(parentCoordinator: AppCoordinatorViewModel) -> DashboardCoordinator {
        DashboardCoordinator(viewModel: DashboardCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }
}
