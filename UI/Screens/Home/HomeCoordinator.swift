import FlowStacks
import SwiftUI

class HomeCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case tutorial
        case settings
        case bleScan
        case bleAutoConnect
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = HomeServiceLocator.instance.provideHomeView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator? = nil) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .tutorial: TutorialServiceLocator.instance.provideTutorialView(coordinator: self)
        case .settings: CoordinatorServiceLocator.instance.provideSettingsCoordinator(parentCoordinator: self)
        case .bleScan: BleScanServiceLocator.instance.provideBleScanView(coordinator: self)
        case .bleAutoConnect: CoordinatorServiceLocator.instance.provideBleAutoConnectCoordinator(parentCoordinator: self)
        }
    }

    @MainActor
    func showTutorial() {
        show(.tutorial)
    }

    @MainActor
    func showSettings() {
        show(.settings)
    }

    @MainActor
    func showBleScan() {
        show(.bleScan)
    }

    @MainActor
    func showBleAutoConnect() {
        show(.bleAutoConnect)
    }
}

struct HomeCoordinator: View {
    @ObservedObject var viewModel: HomeCoordinatorViewModel

    init(viewModel: HomeCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: HomeCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
