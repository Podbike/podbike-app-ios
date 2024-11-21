import SwiftUI

class TutorialViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let userPreferences: UserPreferences

    @Published var selectedPage: Int

    init(coordinator: BaseCoordinator, userPreferences: UserPreferences, startFromPage: Int? = nil) {
        self.coordinator = coordinator
        self.userPreferences = userPreferences
        self.selectedPage = startFromPage ?? 1
    }

    func closeTutorial() {
        userPreferences.isTutorialShown = true
        coordinator?.dismiss()
    }
}
