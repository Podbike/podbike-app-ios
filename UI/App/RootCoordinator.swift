import FlowStacks
import SwiftUI

class RootCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case tutorial
        case settings
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = HomeServiceLocator.instance.provideHomeView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .tutorial: TutorialServiceLocator.instance.provideTutorialView(coordinator: self)
        case .settings: CoordinatorServiceLocator.instance.provideSettingsCoordinator(parentCoordinator: self)
        }
    }

    func showTutorial() {
        show(.tutorial)
    }

    func showSettings() {
        show(.settings)
    }
}

struct RootCoordinator: View {
    @ObservedObject var viewModel: RootCoordinatorViewModel

    init(viewModel: RootCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: RootCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
