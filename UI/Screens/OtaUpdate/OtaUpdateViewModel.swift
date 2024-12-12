import Foundation

class OtaUpdateViewModel: BaseViewModel {
    private weak var coordinator: OtaUpdateCoordinatorViewModel?
    private let otaUpdateManager: OtaUpdateManagerProtocol

    private var updateCheckTask: Task<Void, Never>?
    private var transferTask: Task<Void, Never>?

    @Published private(set) var isCheckingForUpdate: Bool = false
    @Published private(set) var isUpdateAvailable: Bool?
    @Published var showUpdateCheckError: Bool = false
    @Published var updateCheckError: Error?
    @Published var otaLicense: String = ""

    @Published private(set) var isDownloadingOtaFiles: Bool = false
    @Published private(set) var isTransferingOtaFiles: Bool = false
    @Published private(set) var isTransferFinished: Bool = false

    @Published private(set) var otaUpdateFiles: OtaUpdateFiles?
    @Published var transferError: Error?
    @Published var showTransferError: Bool = false

    struct TransferProgress {
        var fileProgress: Double = 0
        var currentFile: Int = 0
        var totalFiles: Int = 0
    }

    @Published var fileTransferProgress = TransferProgress()

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
        transferTask?.cancel()
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
                _ = { [weak self] in
                    self?.isUpdateAvailable = isUpdateAvailable
                    self?.fetchLicense()
                }()
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
            let licenseText = otaLicense ?? String(localized: "UpdateLicenseLoadError")
            _ = { [weak self] in self?.otaLicense = licenseText }()
        }
    }

    func transferFiles() {
        transferTask?.cancel()
        isTransferFinished = false

        transferTask = Task { @MainActor in
            isTransferFinished = false

            guard let files = await downloadOtaUpdateFiles() else {
                transferError = OtaUpdateError.downloadError
                return
            }

            isTransferFinished = await transferFiles(files)
        }
    }

    func stopTransfer() {
        otaUpdateManager.abortTransfer()
        transferTask?.cancel()
        transferTask = nil
    }

    @MainActor
    private func downloadOtaUpdateFiles() async -> OtaUpdateFiles? {
        transferError = nil
        isDownloadingOtaFiles = true
        do {
            let otaUpdateFiles = try await otaUpdateManager.downloadOtaUpdateFiles()
            _ = { [weak self] in self?.otaUpdateFiles = otaUpdateFiles }()
        } catch {
            transferError = error
            showTransferError = true
        }
        isDownloadingOtaFiles = false
        return otaUpdateFiles
    }

    @MainActor
    private func transferFiles(_ otaUpdateFiles: OtaUpdateFiles) async -> Bool {
        transferError = nil
        isTransferingOtaFiles = true
        do {
            let firmwareFiles = otaUpdateFiles.firmwareFiles
            let audioFiles = otaUpdateFiles.audioFiles
            let allFiles = firmwareFiles + audioFiles

            for (fileIndex, otaFile) in allFiles.enumerated() {
                if Task.isCancelled { break }
                let fileProgress = otaUpdateManager.transferFile(otaFile)

                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    fileProgress.sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .failure(let error):
                                continuation.resume(throwing: error)
                            case .finished:
                                continuation.resume()
                            }

                        },
                        receiveValue: { [weak self] progress in
                            self?.fileTransferProgress = TransferProgress(
                                fileProgress: progress,
                                currentFile: fileIndex + 1,
                                totalFiles: firmwareFiles.count
                            )
                        }
                    )
                    .store(in: &cancellables)
                }
            }
        } catch OtaUpdateError.transferCancelled {
        } catch {
            transferError = error
            showTransferError = true
        }
        isTransferingOtaFiles = false

        return transferError == nil
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
    func goToOtaTransferScreen() {
        coordinator?.showOtaTransferScreen()
    }

    @MainActor
    func goToUpgradeScreen() {
        coordinator?.showOtaUpgradeScreen()
        otaUpdateManager.runUpgrade()
    }

    @MainActor
    func goBackToSettings() {
        coordinator?.dismissUpdate()
    }
}
