import Foundation

class FrikarInfoViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let bleManager: BleManager

    @Published private(set) var frikarConfig: FrikarConfig? = nil

    init(
        coordinator: BaseCoordinator?,
        bleManager: BleManager
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager

        super.init()

        fetchData()
    }

    private func fetchData() {
        Task { @MainActor in
            frikarConfig = await bleManager.getFrikarConfig()
        }
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
