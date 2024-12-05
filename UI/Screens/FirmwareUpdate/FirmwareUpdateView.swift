import SwiftUI

struct FirmwareUpdateView: View {
    @ObservedObject var viewModel: FirmwareUpdateViewModel

    init(viewModel: FirmwareUpdateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

        }
        .toolbar(
            title: "UpdatePageTitle",
            onBack: viewModel.dismiss
        )
    }
}

#Preview {
    FirmwareUpdateServiceLocator.instance.provideFirmwareUpdateView(coordinator: nil)
}
