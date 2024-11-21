import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: AppDimens.padding16) {
                Image(.logo)

                AppSpacers.h48

                Button(
                    "Tutorial",
                    action: { viewModel.goToTutorial() }
                )
                .buttonStyle(AppButton.primaryProminent)

                Button(
                    "Settings",
                    action: { viewModel.goToSettings() }
                )
                .buttonStyle(AppButton.primaryProminent)

                Button(
                    "BLE Scan",
                    action: { viewModel.goToBleScan() }
                )
                .buttonStyle(AppButton.primaryProminent)
            }
            .padding(AppDimens.padding16)
        }
    }
}

#Preview {
    HomeServiceLocator.instance.provideHomeView(coordinator: RootCoordinatorViewModel())
}
