import Foundation

class SettingsViewModel: ObservableObject {
    private weak var coordinator: RootCoordinatorViewModel?

    init(coordinator: RootCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    func dismiss() {
        coordinator?.dismiss()
    }
}
