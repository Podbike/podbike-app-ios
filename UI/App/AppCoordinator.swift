import FlowStacks
import SwiftUI

class AppCoordinatorViewModel: BaseViewModel, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case splashScreen
        case dashboard
        case tutorial
        case bleScan
        case bleAutoConnect
    }

    let parentCoordinator: BaseCoordinator? = nil
    var rootView = EmptyView()

    @Published var routes: Routes<Screen> = [.root(.splashScreen)]
    var canGoBack: Bool = false

    var retainedViews: [Screen: AnyView] = [:]

    private let userPreferences: UserPreferences
    private let bleManager: BleManager

    @Published var connectingDevice: BleDevice?

    private lazy var dashboardView = CoordinatorServiceLocator.instance.provideDashboardCoordinator(parentCoordinator: self)

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .splashScreen: SplashServiceLocator.instance.provideSplashView(coordinator: self)
        case .dashboard: dashboardView
        case .tutorial: TutorialServiceLocator.instance.provideTutorialView(coordinator: self)
        case .bleScan: BleScanServiceLocator.instance.provideBleScanView(coordinator: self)
        case .bleAutoConnect: BleAutoConnectServiceLocator.instance.provideBleAutoConnectView(coordinator: self)
        }
    }

    init(bleManager: BleManager, userPreferences: UserPreferences) {
        self.bleManager = bleManager
        self.userPreferences = userPreferences

        super.init()

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        bleManager.connectingDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.connectingDevice = $0 }
            .store(in: &cancellables)
    }

    func updateViews() -> [Screen: AnyView] {
        var viewsMap: [Screen: AnyView] = [:]

        for screen in routes.map(\.screen) {
            viewsMap[screen] = retainedViews[screen]
        }

        let currentScreen = routes.last!.screen
        if viewsMap[currentScreen] == nil {
            viewsMap[currentScreen] = AnyView(provideView(forScreen: currentScreen))
        }

        retainedViews = viewsMap
        return retainedViews
    }

    func showBleScanScreen() {
        routes = [.root(.dashboard), .push(.bleScan)]
    }

    func showTheApp() {
        // routes stack
        routes = [.root(.dashboard)]

        if userPreferences.storedDevices.isEmpty {
            routes.append(.push(.bleScan))
        } else {
            routes.append(.push(.bleAutoConnect))
        }

        if !userPreferences.isTutorialShown {
            routes.append(.push(.tutorial))
        }
    }

    func onConnectionCancelled() {
        bleManager.disconnect()
        if routes.last!.screen == .dashboard {
            let isDashboardRoot = !dashboardView.viewModel.canGoBack
            if isDashboardRoot {
                showBleScanScreen()
            }
        }
    }

    var isUpgrading: Bool {
        guard let connectingDevice = connectingDevice else { return false }
        let storedConnectingDevice = userPreferences.storedDevices
            .first(
                where: { $0.deviceId == connectingDevice.deviceId }
            )
        return storedConnectingDevice?.updateStarted ?? false
    }
}

struct AppCoordinator: View {
    @ObservedObject var viewModel: AppCoordinatorViewModel

    init(viewModel: AppCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            let views = viewModel.updateViews()

            let root = viewModel.routes.last!
            views[root.screen]
                .animation(.default, value: viewModel.routes)

            let isConnecting = viewModel.connectingDevice != nil
            let isAutoConnect = root.screen == .bleAutoConnect
            let isUpgrading = viewModel.isUpgrading

            DeviceConnectionModal(
                isPresented: isConnecting && !isAutoConnect && !isUpgrading,
                deviceName: viewModel.connectingDevice?.deviceName ?? "",
                cancelAction: viewModel.onConnectionCancelled
            )
        }
    }
}
