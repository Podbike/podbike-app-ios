import SwiftUI

class OtaUpdateServiceLocator {

    private lazy var otaUpdateViewModel = OtaUpdateViewModel(
        coordinator: coordinator,
        otaUpdateManager: OtaUpdateManager(
            otaService: OtaService(),
            frikarConfigProvider: BleManager.instance
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
}
