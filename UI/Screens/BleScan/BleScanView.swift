import SwiftUI

struct BleScanView: View {
    @ObservedObject var viewModel: BleScanViewModel

    init(viewModel: BleScanViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                AppSpacers.h32

                ProgressView()
                    .controlSize(.large)
                    .opacity(viewModel.isScanning ? 1 : 0)
                    .padding(AppDimens.padding32)

                List {
                    ForEach(viewModel.scannedDevices, id: \.deviceId) {
                        DeviceRow(
                            name: $0.deviceName,
                            uuid: $0.deviceId,
                            action: {}
                        )
                    }
                }
                .listStyle(.plain)
                .transparentListBackground()

                Button(
                    viewModel.isScanning ? "DeviceStopScan" : "DeviceStartScan",
                    action: {
                        viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan()
                    }
                )
                .buttonStyle(AppButton.primaryTall)
                .textCase(.uppercase)
                .padding(AppDimens.padding16)
            }
        }
        .toolbar(
            title: "DevicesPageTitle",
            onBack: viewModel.dismiss
        )
    }
}

struct DeviceRow: View {
    let name: String
    let uuid: String
    let action: () -> Void

    @State var isHighlighted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: action) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(AppFont.large)
                            .foregroundColor(AppColor.text)

                        AppSpacers.h8

                        Text(uuid)
                            .font(AppFont.small)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundColor(Color.gray)
                    }
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

#Preview {
    BleScanServiceLocator.instance.provideBleScanView(coordinator: BleScanCoordinatorViewModel(parentCoordinator: nil))
}
