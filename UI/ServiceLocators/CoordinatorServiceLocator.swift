import Foundation

class CoordinatorServiceLocator {
    static let instance = CoordinatorServiceLocator()

    func provideStartupCoordinator() -> StartupCoordinator {
        StartupCoordinator(
            viewModel: StartupCoordinatorViewModel(userPreferences: UserPreferences())
        )
    }

    func provideDebugHomeCoordinator(parentCoordinator: BaseCoordinator) -> HomeCoordinator {
        HomeCoordinator(viewModel: HomeCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideSettingsCoordinator(parentCoordinator: BaseCoordinator) -> SettingsCoordinator {
        SettingsCoordinator(viewModel: SettingsCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideBleAutoConnectCoordinator(parentCoordinator: BaseCoordinator) -> BleAutoConnectCoordinator {
        BleAutoConnectCoordinator(viewModel: BleAutoConnectCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideDeviceSelectionCoordinator(parentCoordinator: BaseCoordinator) -> DeviceSelectionCoordinator {
        DeviceSelectionCoordinator(viewModel: DeviceSelectionCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideDashboardCoordinator(parentCoordinator: BaseCoordinator) -> DashboardCoordinator {
        DashboardCoordinator(viewModel: DashboardCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }
}
