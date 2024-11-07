import SwiftUI

class TutorialServiceLocator {
    static let instance = TutorialServiceLocator()

    func provideTutorialView(coordinator: RootCoordinatorViewModel, startFromPage: Int? = nil) -> some View {
        let model = TutorialViewModel(coordinator: coordinator, startFromPage: startFromPage)
        return TutorialView(viewModel: model)
    }
}
