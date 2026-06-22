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

private let notAvailable = "N/A"

struct FrikarInfoView: View {
    @ObservedObject var viewModel: FrikarInfoViewModel

    init(viewModel: FrikarInfoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            if let config = viewModel.frikarConfig {
                FrikarConfigView(config)
            } else
            if viewModel.isFetchError {
                Text("AboutDeviceError").label
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .toolbar(
            title: "AboutDevice",
            onBack: viewModel.dismiss
        )
    }
}

struct FrikarConfigView: View {
    private let config: FrikarConfig

    init(_ config: FrikarConfig) {
        self.config = config
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if let productName = config.productName {
                    Text(productName.uppercased())
                        .font(Font.custom(AppFont.appFont, size: 28))
                        .foregroundStyle(AppColor.accent)
                        .centerHorizontally()
                }

                AppSpacers.h(24)

                DataRow("AboutDeviceProductId", config.productId)
                DataRow("AboutDeviceFrameNumber", config.frameNumber)

                ForEach(config.ecuModules ?? [], id: \.hashValue) { ecuModule in
                    AppColor.dimGray
                        .frame(height: 1)
                    EcuModuleSection(ecuModule)
                }
            }
            .padding(.horizontal, AppDimens.padding16)
            .padding(.top, AppDimens.padding24)
        }
    }
}

private struct DataRow: View {
    private let key: LocalizedStringKey
    private let value: String?

    init(_ key: LocalizedStringKey, _ value: String?) {
        self.key = key
        self.value = value
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(key).info
            Text(verbatim: ": ").info
            Text(value ?? notAvailable).info
        }
        .padding(.vertical, 2)
    }
}

private struct EcuModuleSection: View {
    private let ecuModule: EcuModule

    init(_ ecuModule: EcuModule) {
        self.ecuModule = ecuModule
    }

    var body: some View {
        VStack(alignment: .leading) {
            DataRow("AboutDeviceBoardName", ecuModule.boardName)
            DataRow("AboutDeviceBoardId", ecuModule.boardId)
            DataRow("AboutDeviceBoardPosition", ecuModule.boardPosition)
            DataRow("AboutDeviceFirmwareVersion", ecuModule.firmwareVersion)
            DataRow("AboutDeviceSerialNumber", ecuModule.serialNumber)
        }
    }
}

#Preview {
    FrikarInfoServiceLocator.instance.provideFrikarInfoView(coordinator: nil)
}
