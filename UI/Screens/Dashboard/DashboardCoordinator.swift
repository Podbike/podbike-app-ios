import FlowStacks
import SwiftUI

class DashboardCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case settings
        case debugHome
        case bleAutoConnect
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = DashboardServiceLocator.instance.provideDashboardView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .settings: CoordinatorServiceLocator.instance.provideSettingsCoordinator(parentCoordinator: self)
        case .debugHome: CoordinatorServiceLocator.instance.provideDebugHomeCoordinator(parentCoordinator: self)
        case .bleAutoConnect: CoordinatorServiceLocator.instance.provideBleAutoConnectCoordinator(parentCoordinator: self)
        }
    }

    @MainActor
    func showSettingsScreen() {
        show(.settings)
    }

    @MainActor
    func showDebugHomeScreen() {
        show(.debugHome)
    }

    @MainActor
    func showBleAutoConnectScreen() {
        show(.bleAutoConnect)
    }
}

struct DashboardCoordinator: View {
    @ObservedObject var viewModel: DashboardCoordinatorViewModel

    init(viewModel: DashboardCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: DashboardCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
