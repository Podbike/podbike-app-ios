import SwiftUI

struct OtaUpgradeView: View {
    @ObservedObject var viewModel: OtaUpdateViewModel

    init(viewModel: OtaUpdateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                VStack(alignment: .leading, spacing: AppDimens.padding24) {
                    Text("UpdateUpgradeInfo1").info
                    Text("UpdateUpgradeInfo2").info
                    Text("UpdateUpgradeInfo3").info
                }
                .padding(.horizontal, AppDimens.padding16)
                .padding(.top, AppDimens.padding32)

                Spacer()

                ProgressView()
                    .controlSize(.large)
                    .tint(AppColor.accent)
                    .padding(AppDimens.padding16)

                Spacer()

                Button(
                    "Cancel",
                    action: viewModel.goBackToSettings
                )
                .buttonStyle(AppButton.secondary)
            }
        }
        .toolbar(
            title: "UpdatePageTitle",
            showBackButton: false,
            onBack: viewModel.dismiss
        )
    }
}
