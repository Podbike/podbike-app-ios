import SwiftUI

class BleScanServiceLocator {
    static let instance = BleScanServiceLocator()

    func provideBleScanView(coordinator: BleScanCoordinatorViewModel) -> some View {
        let model = BleScanViewModel(
            coordinator: coordinator,
            bleManager: BLEManager.instance
        )
        return BleScanView(viewModel: model)
    }
}
