import FlowStacks
import SwiftUI

class BleAutoConnectCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case bleScan
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = BleAutoConnectServiceLocator.instance.provideBleAutoConnectView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .bleScan: BleScanServiceLocator.instance.provideBleScanView(coordinator: self)
        }
    }

    @MainActor
    func showBleScanScreen() {
        show(.bleScan)
    }

    @MainActor
    func showDashboardScreen() {
        goBackToRoot()
    }
}

struct BleAutoConnectCoordinator: View {
    @ObservedObject var viewModel: BleAutoConnectCoordinatorViewModel

    init(viewModel: BleAutoConnectCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: BleAutoConnectCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
