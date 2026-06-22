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
