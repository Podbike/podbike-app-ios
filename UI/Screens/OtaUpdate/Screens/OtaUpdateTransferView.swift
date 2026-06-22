/*
 * Copyright (C) 2026 Phal AS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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

    private var transferErrorText: String {
        let error = viewModel.transferError
        var errorText = ""

        if let error = error as? OtaUpdateError {
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
