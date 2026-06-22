/*
 * Copyright (C) 2026 Phal AS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import SwiftUI

struct DeviceSelectionView: View {
    @ObservedObject private var viewModel: DeviceSelectionViewModel

    init(viewModel: DeviceSelectionViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                AppSpacers.h32

                List(viewModel.storedDevices, id: \.deviceId) { device in
                    DeviceRow(device: device, viewModel: viewModel)
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
    private let device: StoredDevice
    @ObservedObject var viewModel: DeviceSelectionViewModel

    @State private var showConnectionPrompt = false

    init(device: StoredDevice, viewModel: DeviceSelectionViewModel) {
        self.device = device
        self.viewModel = viewModel
    }

    var body: some View {
        DeviceRowView(
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

private struct DeviceRowView: View {
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
