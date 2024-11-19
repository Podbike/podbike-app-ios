import FlowStacks
import SwiftUI

class AppCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case splashScreen
        case appRoot
        case tutorial
    }

    let parentCoordinator: BaseCoordinator? = nil
    let userPreferences: UserPreferences?
    var rootView = EmptyView()

    @Published var routes: Routes<Screen> = [.root(.splashScreen)]

    init(userPreferences: UserPreferences? = nil) {
        self.userPreferences = userPreferences
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .splashScreen: SplashServiceLocator.instance.provideSplashView(coordinator: self)
        case .appRoot: CoordinatorServiceLocator.instance.provideRootCoordinator(parentCoordinator: self)
        case .tutorial: TutorialServiceLocator.instance.provideTutorialView(coordinator: self)
        }
    }

    func hideSplashScreen() {
        routes = [.root(.appRoot)]
        if !(userPreferences?.isTutorialShown ?? false) {
            routes.append(.push(.tutorial))
        }
    }
}

struct AppCoordinator: View {
    @ObservedObject var viewModel: AppCoordinatorViewModel

    init(viewModel: AppCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let root = viewModel.routes.last!
        viewModel.provideView(forScreen: root.screen)
    }
}
