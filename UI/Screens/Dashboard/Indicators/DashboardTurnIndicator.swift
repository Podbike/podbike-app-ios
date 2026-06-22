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

struct DashboardTurnIndicator: View {
    @ObservedObject var viewModel: DashboardViewModel

    @State var isShowingTurnOverlay = false
    @State var hideTimer: Timer?

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        return GeometryReader { geometry in
            let animationDuration = 0.15
            let screenWidth = geometry.size.width
            ZStack {
                AppColor.backgroundGradient
                    .ignoresSafeArea()

                let indicatorHeight = geometry.size.width
                let indicatorPadding = AppDimens.padding32

                Path {
                    xPath in
                    xPath.move(to: CGPoint(x: indicatorPadding, y: indicatorHeight / 2))
                    xPath.addLine(to: CGPoint(x: screenWidth / 2, y: 0))
                    xPath.addLine(to: CGPoint(x: screenWidth / 2, y: indicatorHeight))
                }
                .fill(AppColor.accent)
                .frame(height: indicatorHeight)
                .opacity(viewModel.isLeftTurnIndicator ? 1 : 0)
                .animation(.linear(duration: animationDuration), value: viewModel.isLeftTurnIndicator)

                Path {
                    xPath in
                    xPath.move(to: CGPoint(x: screenWidth - indicatorPadding, y: indicatorHeight / 2))
                    xPath.addLine(to: CGPoint(x: screenWidth / 2, y: 0))
                    xPath.addLine(to: CGPoint(x: screenWidth / 2, y: indicatorHeight))
                }
                .fill(AppColor.accent)
                .frame(height: indicatorHeight)
                .opacity(viewModel.isRightTurnIndicator ? 1 : 0)
                .animation(.linear(duration: animationDuration), value: viewModel.isRightTurnIndicator)
            }
            .opacity(isShowingTurnOverlay ? 1 : 0)
            .animation(.linear(duration: animationDuration), value: isShowingTurnOverlay)
            .onChange(of: viewModel.isLeftTurnIndicator) { _ in updateVisibility() }
            .onChange(of: viewModel.isRightTurnIndicator) { _ in updateVisibility() }
        }
    }

    private func updateVisibility() {
        let isLeft = viewModel.isLeftTurnIndicator
        let isRight = viewModel.isRightTurnIndicator
        isShowingTurnOverlay = (isLeft || isRight) && !(isLeft && isRight)
//        hideTimer?.invalidate()
//        if viewModel.isLeftTurnIndicator || viewModel.isRightTurnIndicator {
//            isShowingTurnOverlay = true
//        } else {
//            hideTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
//                isShowingTurnOverlay = false
//            }
//        }
    }
}
