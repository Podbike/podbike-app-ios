import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: AppDimens.padding16) {
                Image(.logo)
                AppSpacers.h64
                Button(
                    "Show tutorial",
                    action: { viewModel.goToTutorial() }
                )
                .buttonStyle(AppButton.primary)
            }
            .padding(AppDimens.padding16)
        }
    }
}

#Preview {
    HomeServiceLocator.instance.provideHomeView(coordinator: RootCoordinatorViewModel(parentCoordinator: nil))
}
