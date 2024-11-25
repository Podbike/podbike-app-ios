import FlowStacks
import SwiftUI

class DeviceSelectionCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case bleScan
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = DeviceSelectionServiceLocator.instance.provideDeviceSelectionView(coordinator: self)

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
}

struct DeviceSelectionCoordinator: View {
    @ObservedObject var viewModel: DeviceSelectionCoordinatorViewModel

    init(viewModel: DeviceSelectionCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: DeviceSelectionCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
