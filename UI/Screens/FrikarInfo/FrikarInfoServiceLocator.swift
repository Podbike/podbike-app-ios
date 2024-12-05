import SwiftUI

class FrikarInfoServiceLocator {
    static let instance = FrikarInfoServiceLocator()

    func provideFrikarInfoView(coordinator: BaseCoordinator?) -> some View {
        let model = FrikarInfoViewModel(
            coordinator: coordinator,
            bleManager: BleManager.instance
        )
        return FrikarInfoView(viewModel: model)
    }
}
