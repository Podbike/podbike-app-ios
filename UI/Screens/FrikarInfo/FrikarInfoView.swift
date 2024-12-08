import SwiftUI

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
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        Text(config.productName.uppercased())
                            .font(Font.custom(AppFont.appFont, size: 28))
                            .foregroundStyle(AppColor.accent)
                            .centerHorizontally()

                        AppSpacers.h(24)

                        DataRow("Product ID", config.productId)
                        DataRow("Frame Number", config.frameNumber)

                        ForEach(config.ecuModules, id: \.hashValue) { ecuModule in
                            AppColor.dimGray
                                .frame(height: 1)
                            EcuModuleSection(ecuModule)
                        }
                    }
                    .padding(.horizontal, AppDimens.padding16)
                    .padding(.top, AppDimens.padding24)
                }
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

private struct DataRow: View {
    private let key: LocalizedStringKey
    private let value: String

    init(_ key: LocalizedStringKey, _ value: String) {
        self.key = key
        self.value = value
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(key).info
            Text(": ").info
            Text(value).info
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
            DataRow("Board Name", ecuModule.boardName)
            DataRow("Board Id", ecuModule.boardId)
            DataRow("Board Position", ecuModule.boardPosition)
            DataRow("Firmware Version", ecuModule.firmwareVersion)
            DataRow("Serial Number", ecuModule.serialNumber)
        }
    }
}

#Preview {
    FrikarInfoServiceLocator.instance.provideFrikarInfoView(coordinator: nil)
}
