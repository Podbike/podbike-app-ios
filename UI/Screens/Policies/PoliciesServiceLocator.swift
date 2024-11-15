import SwiftUI

class PoliciesServiceLocator {
    static let instance = PoliciesServiceLocator()

    func providePoliciesView(coordinator: BaseCoordinator?) -> some View {
        let model = PoliciesViewModel(coordinator: coordinator)
        return PoliciesView(viewModel: model)
    }
}
