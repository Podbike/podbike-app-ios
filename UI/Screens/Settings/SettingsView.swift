import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: AppDimens.padding16) {
                Text("Settings page").title
            }
            .padding(AppDimens.padding16)
        }
        .toolbar(title: LocalizedStringKey("SettingsPageTitle"), onBack: viewModel.dismiss)
    }
}

#Preview {
    SettingsServiceLocator.instance.provideSettingsView(coordinator: RootCoordinatorViewModel(parentCoordinator: nil))
}
