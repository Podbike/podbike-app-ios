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

            ScrollView {
                VStack(alignment: .leading) {
                    Text("UpdateLicense").headline
                    AppSpacers.h8
                    Text(viewModel.otaLicense).info
                }
                .alignLeft()
            }
            .padding(.horizontal, AppDimens.padding16)
            .padding(.top, AppDimens.padding32)
            .padding(.bottom, 150)

            VStack {
                Button(
                    "UpdateButtonTransfer",
                    action: {}
                )
                .buttonStyle(AppButton.primaryProminent)

                Button(
                    "Cancel",
                    action: viewModel.goBackToSettings
                )
                .buttonStyle(AppButton.secondary)
            }
            .centerHorizontally()
            .alignBottom()
        }
        .alert(errorText, isPresented: $viewModel.showUpdateCheckError) {}
        .toolbar(
            title: "UpdatePageTitle",
            onBack: viewModel.dismiss
        )
        .onAppear {
            viewModel.fetchLicense()
        }
    }

    private var errorText: String {
        let error = viewModel.updateCheckError
        var errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        return errorText
    }
}
