import SwiftUI

struct BleScanView: View {
    @ObservedObject var viewModel: BleScanViewModel
    @State var showConnectionPrompt = false

    init(viewModel: BleScanViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        let body = ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                if !viewModel.showNavigationBar {
                    Text("DevicesPageTitle").pageTitle
                        .padding(AppDimens.padding16)
                }

                AppSpacers.h32

                ProgressView()
                    .controlSize(.large)
                    .opacity(viewModel.isScanning ? 1 : 0)
                    .padding(AppDimens.padding32)

                List(viewModel.scannedDevices, id: \.deviceId) { device in
                    DeviceRow(device: device, viewModel: viewModel)
                }
                .listStyle(.plain)
                .transparentListBackground()

                ActionButton(viewModel: viewModel)
                    .padding(AppDimens.padding32)
            }
        }
        .onDisappear { viewModel.stopScan() }

        if viewModel.showNavigationBar {
            body.toolbar(
                title: "FrikarScan",
                onBack: viewModel.dismiss
            )
        } else {
            body.navigationBarBackButtonHidden()
        }
    }
}

private struct DeviceRow: View {
    private let device: BleDevice
    @ObservedObject var viewModel: BleScanViewModel

    @State private var showConnectionPrompt = false

    init(device: BleDevice, viewModel: BleScanViewModel) {
        self.device = device
        self.viewModel = viewModel
    }

    var body: some View {
        DeviceRowView(
            name: device.deviceName,
            action: {
                showConnectionPrompt = true
            }
        )
        .alert(
            String(localized: "ConnectTo") + " \(device.deviceName)",
            isPresented: $showConnectionPrompt
        ) {
            Button("OK") {
                Task {
                    await viewModel.connect(to: device)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("DeviceFailure", isPresented: $viewModel.showConnectionFailed) {}
    }
}

private struct DeviceRowView: View {
    let name: String
    let action: () -> Void

    @State var isHighlighted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: action) {
                HStack {
                    Text(name)
                        .font(AppFont.large)
                        .foregroundColor(AppColor.text)
                        .padding(.vertical, AppDimens.padding8)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppDimens.padding8)
            }
            .buttonStyle(RowButtonStyle(isHighlighted: isHighlighted))
            .simultaneousGesture(TapGesture().onEnded {
                isHighlighted = true
                DispatchQueue.main.async {
                    withAnimation {
                        isHighlighted = false
                    }
                }
            })

            AppColor.dimGray
                .frame(height: 1)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(
            .init(top: 0, leading: AppDimens.padding16, bottom: 0, trailing: AppDimens.padding16)
        )
    }

    private struct RowButtonStyle: ButtonStyle {
        let isHighlighted: Bool

        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .background((configuration.isPressed || isHighlighted) ? AppColor.dimGray : Color.clear)
                .contentShape(Rectangle())
        }
    }
}

private struct ActionButton: View {
    @ObservedObject var viewModel: BleScanViewModel
    @State var showAlert = false

    init(viewModel: BleScanViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        switch viewModel.bleState {
        case .ready:
            Button(
                viewModel.isScanning ? "DeviceStopScan" : "DeviceStartScan",
                action: {
                    viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan()
                }
            )
            .buttonStyle(AppButton.primary)

        case .permissionsRequired:
            Button(
                "DeviceBluetoothPermissionsRequired",
                action: viewModel.openAppSettings
            )
            .buttonStyle(AppButton.alert)

        case .bluetoothOff:
            Button(
                "DeviceBluetoothOff",
                action: viewModel.showBleEnablePrompt
            )
            .buttonStyle(AppButton.alert)

        default:
            EmptyView()
        }
    }
}

#Preview {
    BleScanServiceLocator.instance.provideBleScanView(coordinator: nil)
}
