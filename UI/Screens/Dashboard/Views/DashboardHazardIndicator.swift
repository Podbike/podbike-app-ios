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
        hideTimer?.invalidate()
        if viewModel.isHazardIndicator {
            isShowingHazardOverlay = true
        } else {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { _ in
                isShowingHazardOverlay = false
            }
        }
    }
}
