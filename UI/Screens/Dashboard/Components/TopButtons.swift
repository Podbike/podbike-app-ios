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

struct TopButtons: View {
    @ObservedObject var viewModel: DashboardViewModel
    let rowHeight: Double

    var body: some View {
        HStack {
            Button(action: viewModel.toggleHelp) {
                AppIcon.help.size(rowHeight).foregroundStyle(AppColor.white)
            }

            Spacer()

            Button(action: viewModel.goToStatisticsScreen) {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 42)
            }
            .modifier(Shake(animatableData: viewModel.isShowingHelpInfo ? 1 : 0))
            .animation(
                .spring(duration: 4, bounce: 1).repeatForever(),
                value: viewModel.isShowingHelpInfo
            )

            Spacer()

            Button(action: viewModel.goToSettingsScreen) {
                AppIcon.settings.size(rowHeight).foregroundStyle(AppColor.white)
            }
        }
    }

    struct Shake: GeometryEffect {
        var amount: CGFloat = 3
        var shakesPerUnit = 3
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(
                CGAffineTransform(
                    translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                    y: 0
                )
            )
        }
    }
}
