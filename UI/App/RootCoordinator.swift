import FlowStacks
import SwiftUI

class RootCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case tutorial
    }

    let parentCoordinator: (any BaseCoordinatorViewModelProtocol)?

    lazy var rootView: some View = HomeServiceLocator.instance.provideHomeView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: (any BaseCoordinatorViewModelProtocol)?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .tutorial: TutorialServiceLocator.instance.provideTutorialView(coordinator: self)
        }
    }

    func showTutorial() {
        show(.tutorial)
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
