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

struct DashboardHazardIndicator: View {
    @ObservedObject var viewModel: DashboardViewModel

    @State var isShowingHazardOverlay = false
    @State var hideTimer: Timer?

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        return ZStack {
            Color.red
                .ignoresSafeArea()

            Image(.hazard)
                .resizable()
                .scaledToFit()
                .padding(AppDimens.padding64)
                .opacity(viewModel.isHazardIndicator ? 1 : 0)
                .animation(.linear(duration: 0.15), value: viewModel.isHazardIndicator)
        }
        .opacity(isShowingHazardOverlay ? 1 : 0)
        .animation(.linear(duration: 0.15), value: isShowingHazardOverlay)
        .onChange(of: viewModel.isHazardIndicator) { _ in updateVisibility() }
    }

    private func updateVisibility() {
        isShowingHazardOverlay = viewModel.isHazardIndicator
//        hideTimer?.invalidate()
//        if viewModel.isHazardIndicator {
//            isShowingHazardOverlay = true
//        } else {
//            hideTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
//                isShowingHazardOverlay = false
//            }
//        }
    }
}
