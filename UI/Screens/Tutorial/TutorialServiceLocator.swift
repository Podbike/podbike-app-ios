import SwiftUI

class TutorialServiceLocator {
    static let instance = TutorialServiceLocator()

    func provideTutorialView(coordinator: RootCoordinatorViewModel) -> some View {
        let model = TutorialViewModel(coordinator: coordinator)
        return TutorialView(viewModel: model)
    }
}
