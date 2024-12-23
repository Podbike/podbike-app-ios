import SwiftUI

struct OtaUpdateCheckView: View {
    @ObservedObject var viewModel: OtaUpdateViewModel

    init(viewModel: OtaUpdateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            let hasUpdate = viewModel.isUpdateAvailable == true

            if viewModel.isCheckingForUpdate {
                ProgressView()
                    .controlSize(.large)
                    .centerVertically()
            } else if viewModel.updateCheckError == nil {
                Text(hasUpdate ? "UpdateAvailable" : "UpdateCurrent").title
                    .padding(.horizontal, AppDimens.padding32)
                    .padding(.bottom, 100)
            }

            Button(
                hasUpdate ? "UpdateButtonGet" : "UpdateButtonCheck",
                action: {
                    hasUpdate ? viewModel.goToLicenseScreen() : viewModel.checkForUpdate()
                }
            )
            .buttonStyle(hasUpdate ? AppButton.primaryProminent : AppButton.primary)
            .padding(.bottom, AppDimens.padding48)
            .opacity(viewModel.isCheckingForUpdate ? 0 : 1)
            .alignBottom()
        }
        .alert(errorText, isPresented: $viewModel.showUpdateCheckError) {}
        .toolbar(
            title: "UpdatePageTitle",
            onBack: viewModel.dismiss
        )
    }

    private var errorText: String {
        let error = viewModel.updateCheckError
        var errorText: String = ""
        if let error = error as? OtaUpdateError, case error = OtaUpdateError.frikarConfigFetchError {
            errorText = String(localized: "UpdateMissingDevice")
        } else {
            errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        }
        return errorText
    }
}

#Preview {
    OtaUpdateServiceLocator(coordinator: nil).provideOtaUpdateCheckView()
}
