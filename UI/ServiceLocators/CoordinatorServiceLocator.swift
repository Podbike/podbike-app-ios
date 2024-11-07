import Foundation

class CoordinatorServiceLocator {
    static let instance = CoordinatorServiceLocator()

    func provideAppCoordinator() -> AppCoordinator {
        AppCoordinator(viewModel: AppCoordinatorViewModel())
    }

    func provideRootCoordinator(parentCoordinator: (any BaseCoordinatorViewModelProtocol)?) -> RootCoordinator {
        RootCoordinator(viewModel: RootCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }
}
