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

            let isInProgress = viewModel.isDownloadingOtaFiles || viewModel.isTransferingOtaFiles

            if isInProgress {
                VStack(alignment: .leading) {
                    Text("UpdateTransfer").headline
                    AppSpacers.h16
                    Text("UpdateTransferInfo").info
                }
                .alignTop()
                .alignLeft()
                .padding(.horizontal, AppDimens.padding16)
                .padding(.top, AppDimens.padding32)
            }

            VStack {
                ProgressView()
                    .tint(AppColor.accent)
                    .opacity(isInProgress ? 1 : 0)

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
            .opacity(viewModel.isTransferFinished ? 1 : 0)
        }
        .alert(updateCheckErrorText, isPresented: $viewModel.showUpdateCheckError) {}
        .alert(transferErrorText, isPresented: $viewModel.showTransferError) {}
        .toolbar(
            title: "UpdatePageTitle",
            onBack: viewModel.dismiss
        )
        .onAppear {
            viewModel.transferFiles()
        }
    }

    private var updateCheckErrorText: String {
        let error = viewModel.updateCheckError
        let errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        return errorText
    }

    private var transferErrorText: String {
        let error = viewModel.transferError
        let errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
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
