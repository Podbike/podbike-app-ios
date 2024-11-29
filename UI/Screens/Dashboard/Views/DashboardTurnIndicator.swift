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
        hideTimer?.invalidate()
        if viewModel.isLeftTurnIndicator || viewModel.isRightTurnIndicator {
            isShowingTurnOverlay = true
        } else {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
                isShowingTurnOverlay = false
            }
        }
    }
}
