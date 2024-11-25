import FlowStacks
import SwiftUI

class StartupCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case splashScreen
        case dashboard
        case tutorial
        case bleScan
        case bleAutoConnect
    }

    let parentCoordinator: BaseCoordinator? = nil
    let userPreferences: UserPreferences
    var rootView = EmptyView()

    var canGoBack: Bool = false

    private lazy var dashboardView = CoordinatorServiceLocator.instance.provideDashboardCoordinator(parentCoordinator: self)

    @Published var routes: Routes<Screen> = [.root(.splashScreen)]

    init(userPreferences: UserPreferences) {
        self.userPreferences = userPreferences
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .splashScreen: SplashServiceLocator.instance.provideSplashView(coordinator: self)
        case .dashboard: dashboardView
        case .tutorial: TutorialServiceLocator.instance.provideTutorialView(coordinator: self)
        case .bleScan: BleScanServiceLocator.instance.provideBleScanView(coordinator: self)
        case .bleAutoConnect: CoordinatorServiceLocator.instance.provideBleAutoConnectCoordinator(parentCoordinator: self)
        }
    }

    func showTheApp() {
        //routes stack
        routes = [.root(.dashboard)]

        if userPreferences.storedDevices.isEmpty {
            routes.append(.push(.bleScan))
        } else {
            routes.append(.push(.bleAutoConnect))
        }

        if !userPreferences.isTutorialShown {
            routes.append(.push(.tutorial))
        }
    }
}

struct StartupCoordinator: View {
    @ObservedObject var viewModel: StartupCoordinatorViewModel

    init(viewModel: StartupCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let root = viewModel.routes.last!
        viewModel.provideView(forScreen: root.screen)
            .animation(.default, value: viewModel.routes)
    }
}
