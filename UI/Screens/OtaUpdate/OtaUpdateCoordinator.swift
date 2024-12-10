import FlowStacks
import SwiftUI

class OtaUpdateCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case otaLicense
    }

    let parentCoordinator: BaseCoordinator?
    private lazy var serviceLocator = OtaUpdateServiceLocator(coordinator: self)

    lazy var rootView: some View = serviceLocator.provideOtaUpdateCheckView()

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .otaLicense: serviceLocator.provideOtaUpdateLicenseView()
        }
    }

    @MainActor
    func showLicenseScreen() {
        show(.otaLicense)
    }

    @MainActor
    func dismissUpdate() {
        routes.goBackToRoot()
        parentCoordinator?.dismiss()
    }
}

struct OtaUpdateCoordinator: View {
    @ObservedObject var viewModel: OtaUpdateCoordinatorViewModel

    init(viewModel: OtaUpdateCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: OtaUpdateCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
