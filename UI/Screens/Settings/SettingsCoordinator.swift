import FlowStacks
import SwiftUI

class SettingsCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case deviceSelection
        case firmwareUpdate
        case frikarInfo
        case policies
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
        case .deviceSelection: CoordinatorServiceLocator.instance.provideDeviceSelectionCoordinator(parentCoordinator: self)
        case .firmwareUpdate: CoordinatorServiceLocator.instance.provideFirmwareUpdateCoordinator(parentCoordinator: self)
        case .frikarInfo: FrikarInfoServiceLocator.instance.provideFrikarInfoView(coordinator: self)
        case .policies: PoliciesServiceLocator.instance.providePoliciesView(coordinator: self)
        }
    }

    @MainActor
    func showDeviceSelection() {
        show(.deviceSelection)
    }

    @MainActor
    func showFirmwareUpdate() {
        show(.firmwareUpdate)
    }

    @MainActor
    func showPolicies() {
        show(.policies)
    }

    @MainActor
    func showFrikarInfo() {
        show(.frikarInfo)
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
