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
        if let error = error as? OtaUpdateError {
            errorText = error == OtaUpdateError.frikarConfigFetchError ? String(localized: "UpdateMissingDevice") : String(localized: "UpdateIssue")
        } else {
            errorText = error?.localizedDescription ?? String(localized: "UpdateIssue")
        }
        return errorText
    }
}

#Preview {
    OtaUpdateServiceLocator(coordinator: nil).provideOtaUpdateCheckView()
}
