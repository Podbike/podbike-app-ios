import SwiftUI

class TutorialViewModel: ObservableObject {
    private weak var coordinator: RootCoordinatorViewModel?

    @Published var selectedPage: Int

    init(coordinator: RootCoordinatorViewModel, startFromPage: Int? = nil) {
        self.coordinator = coordinator
        self.selectedPage = startFromPage ?? 1
    }

    func closeTutorial() {
        coordinator?.dismiss()
    }
}
