import Foundation

class SplashViewModel: BaseViewModel {
    private weak var coordinator: AppCoordinatorViewModel?

    enum Constants {
        static let splashDurationInSeconds = 2.0
    }

    init(coordinator: AppCoordinatorViewModel?) {
        self.coordinator = coordinator
    }

    func didAppear() {
        waitAndShowTheApp()
    }

    private func waitAndShowTheApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.splashDurationInSeconds) { [weak self] in
            self?.coordinator?.showTheApp()
        }
    }
}
