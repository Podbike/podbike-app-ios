import Foundation

class HomeViewModel: ObservableObject {
    private weak var coordinator: RootCoordinatorViewModel?

    init(coordinator: RootCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    func goToTutorial() {
        coordinator?.showTutorial()
    }
}
