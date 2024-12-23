import SwiftUI

struct OtaUpdateTransferView: View {
    @ObservedObject var viewModel: OtaUpdateViewModel

    init(viewModel: OtaUpdateViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            if !viewModel.isTransferFinished {
                VStack(alignment: .leading) {
                    Text("UpdateTransfer").headline
                    AppSpacers.h16
                    Text("UpdateTransferInfo").info
                }
                .alignTop()
                .alignLeft()
                .padding(.horizontal, AppDimens.padding16)
                .padding(.top, AppDimens.padding32)

                VStack {
                    ProgressView()
                        .tint(AppColor.accent)

                    AppSpacers.h32

                    ZStack {
                        Text("UpdateDownloading").title
                            .opacity(viewModel.isDownloadingOtaFiles ? 1 : 0)

                        VStack {
                            Text(transferStatus).title

                            AppSpacers.h32

                            let fileProgress = viewModel.fileTransferProgress.fileProgress
                            ProgressView(value: fileProgress, total: 100)
                                .tint(AppColor.accent)
                                .scaleEffect(x: 1, y: 3, anchor: .center)
                                .padding(.horizontal, AppDimens.padding48)
                        }
                        .opacity(viewModel.isTransferingOtaFiles ? 1 : 0)
                    }
                }
                .padding(.horizontal, AppDimens.padding16)

                Button(
                    "Cancel",
                    action: viewModel.goBackToSettings
                )
                .buttonStyle(AppButton.secondary)
                .padding(.horizontal, AppDimens.padding16)
                .alignBottom()
            } else {
                VStack {
                    ZStack {
                        Text("UpdateTransferComplete").title
                    }
                    .frame(maxHeight: .infinity)

                    VStack {
                        Button(
                            "UpdateButtonUpgrade",
                            action: viewModel.goToUpgradeScreen
                        )
                        .buttonStyle(AppButton.primaryProminent)

                        Button(
                            "Cancel",
                            action: viewModel.goBackToSettings
                        )
                        .buttonStyle(AppButton.secondary)
                    }
                }
                .padding(.horizontal, AppDimens.padding16)
            }
        }
        .alert(updateCheckErrorText, isPresented: $viewModel.showUpdateCheckError) {}
        .alert(transferErrorText, isPresented: $viewModel.showTransferError) {
            Button("OK") { viewModel.goBackToSettings() }
        }
        .toolbar(
            title: "UpdatePageTitle",
            showBackButton: false,
            onBack: viewModel.dismiss
        )
        .onAppear {
            viewModel.transferFiles()
        }
        .onDisappear {
            viewModel.stopTransfer()
        }
    }

    private var updateCheckErrorText: String {
        let error = viewModel.updateCheckError
        let errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        return errorText
    }

    private var transferErrorText: String {
        let error = viewModel.transferError
        var errorText = ""

        if let error = error as? OtaUpdateError, case error = OtaUpdateError.downloadError {
            errorText = error == OtaUpdateError.downloadError ?
                String(localized: "UpdateDownloadIssue") :
                String(localized: "UpdateIssue")
        } else {
            errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        }
        return errorText
    }

    private var transferStatus: String {
        let fileProgress = viewModel.fileTransferProgress
        let status =
            String(localized: "UpdateSent") +
            " \(fileProgress.currentFile) " +
            String(localized: "UpdateOutOf") +
            " \(fileProgress.totalFiles) " +
            String(localized: "UpdateFiles")
        return status
    }
}

#Preview {
    OtaUpdateServiceLocator(coordinator: nil).provideOtaUpdateTransferView()
}
