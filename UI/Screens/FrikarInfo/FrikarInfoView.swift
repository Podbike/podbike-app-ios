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
            Text(": ").info
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
