import SwiftUI

class SplashServiceLocator {
    static let instance = SplashServiceLocator()

    func provideSplashView(coordinator: StartupCoordinatorViewModel?) -> some View {
        let model = SplashViewModel(coordinator: coordinator)
        return SplashView(viewModel: model)
    }
}
