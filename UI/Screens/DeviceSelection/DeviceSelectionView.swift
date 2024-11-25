import SwiftUI

struct DeviceSelectionView: View {
    @ObservedObject var viewModel: DeviceSelectionViewModel
    @State var showConnectionPrompt = false

    init(viewModel: DeviceSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                AppSpacers.h32

                List {
                    ForEach(viewModel.storedDevices, id: \.deviceId) { device in
                        DeviceRow(
                            name: device.deviceName,
                            isSelected: device == viewModel.storedDevices.first,
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
                .listStyle(.plain)
                .transparentListBackground()

                AppSpacers.h64

                Button(
                    "FrikarScan",
                    action: {
                        viewModel.goToBleScanScreen()
                    }
                )
                .buttonStyle(AppButton.primary)
                .padding(AppDimens.padding32)
            }
        }
        .toolbar(
            title: "DevicesPageTitle",
            onBack: viewModel.dismiss
        )
    }
}

private struct DeviceRow: View {
    let name: String
    let isSelected: Bool
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
                    if isSelected {
                        AppIcon.check
                            .size(36)
                            .foregroundStyle(AppColor.white)
                    }
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

#Preview {
    DeviceSelectionServiceLocator.instance.provideDeviceSelectionView(coordinator: nil)
}
