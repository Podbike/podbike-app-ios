import Foundation

class CoordinatorServiceLocator {
    static let instance = CoordinatorServiceLocator()

    func provideAppCoordinator() -> AppCoordinator {
        AppCoordinator(viewModel: AppCoordinatorViewModel())
    }

    func provideRootCoordinator(parentCoordinator: BaseCoordinator?) -> RootCoordinator {
        RootCoordinator(viewModel: RootCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideSettingsCoordinator(parentCoordinator: BaseCoordinator) -> SettingsCoordinator {
        SettingsCoordinator(viewModel: SettingsCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }
}
