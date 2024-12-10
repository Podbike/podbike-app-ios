import Foundation

class OtaUpdateViewModel: BaseViewModel {
    private weak var coordinator: OtaUpdateCoordinatorViewModel?
    private let otaUpdateManager: OtaUpdateManagerProtocol

    private var updateCheckTask: Task<Void, Never>?

    @Published private(set) var isCheckingForUpdate: Bool = false
    @Published private(set) var isUpdateAvailable: Bool?
    @Published var showUpdateCheckError: Bool = false
    @Published var updateCheckError: Error?
    @Published var otaLicense: String = ""

    init(
        coordinator: OtaUpdateCoordinatorViewModel?,
        otaUpdateManager: OtaUpdateManagerProtocol
    ) {
        self.coordinator = coordinator
        self.otaUpdateManager = otaUpdateManager

        super.init()

        checkForUpdate()
    }

    deinit {
        updateCheckTask?.cancel()
    }

    func checkForUpdate() {
        updateCheckTask?.cancel()
        isUpdateAvailable = nil
        showUpdateCheckError = false
        updateCheckError = nil
        isCheckingForUpdate = true

        updateCheckTask = Task { @MainActor [weak self] in
            do {
                let isUpdateAvailable = try await self?.otaUpdateManager.isUpdateAvailable()
                _ = { [weak self] in self?.isUpdateAvailable = isUpdateAvailable }()
            } catch {
                self?.updateCheckError = error
                self?.showUpdateCheckError = true
            }
            self?.isCheckingForUpdate = false
        }
    }

    func fetchLicense() {
        Task { @MainActor [weak self] in
            let otaLicense = try? await self?.otaUpdateManager.getOtaUpdateLicense()
            _ = { [weak self] in self?.otaLicense = otaLicense ?? "" }()
        }
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }

    @MainActor
    func goToLicenseScreen() {
        coordinator?.showLicenseScreen()
    }

    @MainActor
    func goBackToSettings() {
        coordinator?.dismissUpdate()
    }
}
