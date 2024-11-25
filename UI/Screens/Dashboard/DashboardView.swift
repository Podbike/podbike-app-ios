import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: viewModel.goToDebugHomeScreen) {
                        AppIcon.help.size(64).foregroundStyle(AppColor.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(.logoSmall)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 42)
                    }
                    Spacer()
                    Button(action: viewModel.goToSettingsScreen) {
                        AppIcon.settings.size(64).foregroundStyle(AppColor.white)
                    }


                }

                Text("57")
                    .font(Font.custom(AppFont.appFont, size: 300))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal, AppDimens.padding32)

                Spacer()
                    .frame(height: 200)

                if let connectedDevice = viewModel.connectedDevice {
                    Text("Connected to:\n\(connectedDevice.deviceName)").label
                } else {
                    Text("Disconnected")
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.alert)
                }

                Spacer()
            }
            .padding(AppDimens.padding16)
        }
        .navigationBarBackButtonHidden()
        .colorScheme(.dark)
        .onAppear {
            if viewModel.connectedDevice == nil {
                viewModel.reconnect()
            }
        }
    }
}

#Preview {
    DashboardServiceLocator.instance.provideDashboardView(coordinator: DashboardCoordinatorViewModel(parentCoordinator: nil))
}
