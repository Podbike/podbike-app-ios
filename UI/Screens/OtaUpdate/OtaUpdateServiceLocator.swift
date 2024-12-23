import SwiftUI

class OtaUpdateServiceLocator {

    private lazy var otaUpdateViewModel = OtaUpdateViewModel(
        coordinator: coordinator,
        otaUpdateManager: OtaUpdateManager(
            otaService: OtaService(),
            frikarConfigProvider: BleManager.instance.ymodemController,
            fileTransferHandler: BleManager.instance.ymodemController,
            userPreferences: UserPreferences.instance
        )
    )

    private let coordinator: OtaUpdateCoordinatorViewModel?

    init(coordinator: OtaUpdateCoordinatorViewModel?) {
        self.coordinator = coordinator
    }

    func provideOtaUpdateCheckView() -> some View {
        return OtaUpdateCheckView(viewModel: otaUpdateViewModel)
    }

    func provideOtaUpdateLicenseView() -> some View {
        return OtaUpdateLicenseView(viewModel: otaUpdateViewModel)
    }

    func provideOtaUpdateTransferView() -> some View {
        return OtaUpdateTransferView(viewModel: otaUpdateViewModel)
    }

    func provideOtaUpgradeView() -> some View {
        return OtaUpgradeView(viewModel: otaUpdateViewModel)
    }
}
