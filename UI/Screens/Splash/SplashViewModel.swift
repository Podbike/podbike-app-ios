import Foundation

class SplashViewModel {
    private weak var coordinator: AppCoordinatorViewModel?

    struct Constants {
        static let splashDurationInSeconds = 2.0
    }

    init(coordinator: AppCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    func didAppear() {
        waitAndGoToHome()
    }

    private func waitAndGoToHome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.splashDurationInSeconds) { [weak self] in
            self?.coordinator?.showHome()
        }
    }
}
