import SwiftUI

struct BleAutoConnectView: View {
    @ObservedObject var viewModel: BleAutoConnectViewModel

    init(viewModel: BleAutoConnectViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        let isBleEnabled = viewModel.bleState != .bluetoothOff
        let isConnecting = viewModel.isConnecting || viewModel.isScanning

        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                // MARK: title

                let deviceName = viewModel.autoConnectDevice?.deviceName ?? ""
                let connectingTitle = String(localized: "ConnectingTo") + " \(deviceName)"
                let bleDisabledTitle = String(localized: "FrikarBluetoothDisabled")
                let title = isBleEnabled ? connectingTitle : bleDisabledTitle
                Text(title)
                    .font(AppFont.large)
                    .foregroundStyle(AppColor.text)
                    .multilineTextAlignment(.center)

                Spacer()

                // MARK: progress view

                ProgressView()
                    .tint(AppColor.accent)
                    .opacity(isConnecting ? 1 : 0)
                    .padding(AppDimens.padding8)

                // MARK: subtitle

                let subtitle: LocalizedStringKey = isBleEnabled ? (isConnecting ? "FrikarConnecting" : "FrikarConnectingPaused") : "FrikarTurnOnBluetooth"
                Text(subtitle).label

                Spacer()
                Spacer()

                // MARK: main button

                if isBleEnabled {
                    Button(
                        isConnecting ? "FrikarPause" : "FrikarResume",
                        action: {
                            isConnecting ? viewModel.stopAutoConnect() : viewModel.startAutoConnect()
                        }
                    )
                    .buttonStyle(AppButton.primary)
                } else {
                    Button(
                        "DeviceToggleAdapter",
                        action: viewModel.showBleEnablePrompt
                    )
                    .buttonStyle(AppButton.primary)
                }

                AppSpacers.h32

                // MARK: scan button

                Button(
                    "FrikarScan",
                    action: {
                        viewModel.goToBleScanScreen()
                    }
                )
                .buttonStyle(AppButton.secondary)

                Spacer()

                // MARK: footer text

                Text("FrikarNotFound")
                    .font(AppFont.small)
                    .italic()
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(AppDimens.padding16)
        }
        .navigationBarBackButtonHidden()
        .colorScheme(.dark)
        .alert("DeviceFailure", isPresented: $viewModel.showConnectionFailed) {}
    }
}

#Preview {
    BleAutoConnectServiceLocator.instance.provideBleAutoConnectView(coordinator: nil)
}
