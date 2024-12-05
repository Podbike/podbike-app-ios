import SwiftUI

struct FrikarInfoView: View {
    @ObservedObject var viewModel: FrikarInfoViewModel

    init(viewModel: FrikarInfoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

        }
        .toolbar(
            title: "AboutDevice",
            onBack: viewModel.dismiss
        )
    }
}

#Preview {
    FrikarInfoServiceLocator.instance.provideFrikarInfoView(coordinator: nil)
}
