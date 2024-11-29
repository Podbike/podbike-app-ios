import SwiftUI

class TutorialServiceLocator {
    static let instance = TutorialServiceLocator()

    func provideTutorialView(coordinator: BaseCoordinator?, startFromPage: Int? = nil) -> some View {
        let model = TutorialViewModel(
            coordinator: coordinator,
            userPreferences: UserPreferences.instance,
            startFromPage: startFromPage
        )
        return TutorialView(viewModel: model)
    }
}
