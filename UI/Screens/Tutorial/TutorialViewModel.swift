import Foundation

class TutorialViewModel: ObservableObject {
    private weak var coordinator: RootCoordinatorViewModel?

    init(coordinator: RootCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    func didAppear() {}
}
