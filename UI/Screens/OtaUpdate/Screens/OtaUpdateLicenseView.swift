import SwiftUI

struct OtaUpdateLicenseView: View {
    @ObservedObject var viewModel: OtaUpdateViewModel

    init(viewModel: OtaUpdateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("UpdateLicense").headline
                        AppSpacers.h16
                        Text(viewModel.otaLicense).info
                    }
                    .alignLeft()
                }
                .padding(.horizontal, AppDimens.padding16)
                .padding(.vertical, AppDimens.padding32)

                Spacer()

                VStack {
                    Button(
                        "UpdateButtonTransfer",
                        action: viewModel.goToOtaTransferScreen
                    )
                    .buttonStyle(AppButton.primaryProminent)

                    Button(
                        "Cancel",
                        action: viewModel.goBackToSettings
                    )
                    .buttonStyle(AppButton.secondary)
                }
            }
        }
        .alert(errorText, isPresented: $viewModel.showUpdateCheckError) {}
        .toolbar(
            title: "UpdatePageTitle",
            onBack: viewModel.dismiss
        )
    }

    private var errorText: String {
        let error = viewModel.updateCheckError
        let errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        return errorText
    }
}

#Preview {
    OtaUpdateServiceLocator(coordinator: nil).provideOtaUpdateLicenseView()
}
