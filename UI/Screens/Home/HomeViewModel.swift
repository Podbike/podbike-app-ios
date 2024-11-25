import Foundation

class HomeViewModel: BaseViewModel {
    private weak var coordinator: HomeCoordinatorViewModel?

    init(coordinator: HomeCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    @MainActor
    func goToTutorial() {
        coordinator?.showTutorial()
    }

    @MainActor
    func goToSettings() {
        coordinator?.showSettings()
    }

    @MainActor
    func goToBleScan() {
        coordinator?.showBleScan()
    }

    @MainActor
    func goToBleAutoConnect() {
        coordinator?.showBleAutoConnect()
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
