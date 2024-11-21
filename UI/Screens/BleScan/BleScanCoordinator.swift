import FlowStacks
import SwiftUI

class BleScanCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case connection
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = BleScanServiceLocator.instance.provideBleScanView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .connection: PoliciesServiceLocator.instance.providePoliciesView(coordinator: self) // TODO
        }
    }

    func showConnectionScreen() {
        show(.connection)
    }
}

struct BleScanCoordinator: View {
    @ObservedObject var viewModel: BleScanCoordinatorViewModel

    init(viewModel: BleScanCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: BleScanCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
