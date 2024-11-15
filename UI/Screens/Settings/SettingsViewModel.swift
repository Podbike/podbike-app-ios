import Foundation
import UIKit

class SettingsViewModel: ObservableObject {
    private weak var coordinator: SettingsCoordinatorViewModel?

    init(coordinator: SettingsCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    func dismiss() {
        coordinator?.dismiss()
    }

    func onLanguageTapped() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    func onPoliciesTapped() {
        coordinator?.showPolicies()
    }
}
