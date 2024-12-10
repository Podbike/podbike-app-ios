import Foundation

class FrikarInfoViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let bleManager: BleManager

    private var dataFetchTask: Task<Void, Never>?

    @Published private(set) var frikarConfig: FrikarConfig?
    @Published private(set) var isFetchError: Bool = false

    init(
        coordinator: BaseCoordinator?,
        bleManager: BleManager
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager

        super.init()

        fetchData()
    }

    deinit {
        dataFetchTask?.cancel()
    }

    private func fetchData() {
        dataFetchTask?.cancel()
        isFetchError = false

        dataFetchTask = Task { @MainActor [weak self] in
            let result = await self?.bleManager.getFrikarConfig()
            _ = { [weak self] in
                self?.frikarConfig = result
                if result == nil { self?.isFetchError = true }
            }()
        }
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
