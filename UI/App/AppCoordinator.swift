import FlowStacks
import SwiftUI

class AppCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case splash
        case appRoot
    }

    let parentCoordinator: (any BaseCoordinatorViewModelProtocol)? = nil
    var rootView = EmptyView()

    @Published var routes: Routes<Screen> = [.root(.splash)]

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .splash: SplashServiceLocator.instance.provideSplashView(coordinator: self)
        case .appRoot: CoordinatorServiceLocator.instance.provideRootCoordinator(parentCoordinator: self)
        }
    }

    func showHome() {
        routes = [.root(.appRoot)]
    }
}

struct AppCoordinator: View {
    @ObservedObject var viewModel: AppCoordinatorViewModel

    init(viewModel: AppCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let root = viewModel.routes.first!
        viewModel.provideView(forScreen: root.screen)
    }
}
