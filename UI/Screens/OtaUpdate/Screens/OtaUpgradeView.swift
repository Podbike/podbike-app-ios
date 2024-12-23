import SwiftUI

struct OtaUpgradeView: View {
    @ObservedObject var viewModel: OtaUpdateViewModel

    init(viewModel: OtaUpdateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("UpdateUpgradeInfo").info
                    .multilineTextAlignment(.center)
                    .padding(AppDimens.padding32)

                Spacer()

                Button(
                    "OK",
                    action: viewModel.goBackToDashboard
                )
                .buttonStyle(AppButton.primaryProminent)
                .padding(.bottom, AppDimens.padding48)
            }
        }
        .toolbar(
            title: "UpdatePageTitle",
            showBackButton: false,
            onBack: viewModel.goBackToDashboard
        )
    }
}

#Preview {
    OtaUpdateServiceLocator(coordinator: nil).provideOtaUpgradeView()
}
