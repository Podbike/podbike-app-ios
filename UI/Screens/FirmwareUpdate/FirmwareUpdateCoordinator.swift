import FlowStacks
import SwiftUI

class FirmwareUpdateCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case updateAvailable
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = FirmwareUpdateServiceLocator.instance.provideFirmwareUpdateView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .updateAvailable: FirmwareUpdateServiceLocator.instance.provideFirmwareUpdateView(coordinator: self) // TODO
        }
    }

    @MainActor
    func showUpdateAvailableScreen() {
        show(.updateAvailable)
    }
}

struct FirmwareUpdateCoordinator: View {
    @ObservedObject var viewModel: FirmwareUpdateCoordinatorViewModel

    init(viewModel: FirmwareUpdateCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: FirmwareUpdateCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
