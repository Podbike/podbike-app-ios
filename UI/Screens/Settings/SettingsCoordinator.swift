import FlowStacks
import SwiftUI

class SettingsCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case policies
        case deviceManagement
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = SettingsServiceLocator.instance.provideSettingsView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .policies: PoliciesServiceLocator.instance.providePoliciesView(coordinator: self)
        case .deviceManagement: CoordinatorServiceLocator.instance.provideBleScanCoordinator(parentCoordinator: self)
        }
    }

    func showDeviceManagement() {
        show(.deviceManagement)
    }

    func showPolicies() {
        show(.policies)
    }
}

struct SettingsCoordinator: View {
    @ObservedObject var viewModel: SettingsCoordinatorViewModel

    init(viewModel: SettingsCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: SettingsCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
