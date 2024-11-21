import Foundation

class HomeViewModel: BaseViewModel {
    private weak var coordinator: RootCoordinatorViewModel?

    init(coordinator: RootCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    func goToTutorial() {
        coordinator?.showTutorial()
    }

    func goToSettings() {
        coordinator?.showSettings()
    }

    func goToBleScan() {
        coordinator?.showBleScan()
    }
}
