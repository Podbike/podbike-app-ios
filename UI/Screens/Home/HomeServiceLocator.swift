import SwiftUI

class HomeServiceLocator {
    static let instance = HomeServiceLocator()

    func provideHomeView(coordinator: HomeCoordinatorViewModel) -> some View {
        let model = HomeViewModel(coordinator: coordinator)
        return HomeView(viewModel: model)
    }
}
