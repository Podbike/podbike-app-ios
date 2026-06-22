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
        .toolbar(
            title: "UpdatePageTitle",
            onBack: viewModel.dismiss
        )
    }
}

#Preview {
    OtaUpdateServiceLocator(coordinator: nil).provideOtaUpdateLicenseView()
}
