import SwiftUI

public struct DeviceConnectionModal: View {
    private let isPresented: Bool
    private let deviceName: String
    private let cancelAction: () -> Void

    public init(isPresented: Bool, deviceName: String, cancelAction: @escaping () -> Void) {
        self.isPresented = isPresented
        self.deviceName = deviceName
        self.cancelAction = cancelAction
    }

    public var body: some View {
        ZStack {
            if isPresented {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    HStack {
                        Spacer()

                        VStack(spacing: 0) {
                            AppSpacers.h16

                            ProgressView()
                                .controlSize(.large)
                                .padding(AppDimens.padding8)

                            let message = String(localized: "ConnectingTo") + "\n" + deviceName
                            Text(message)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColor.text)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppDimens.padding32)

                            AppSpacers.h16

                            Divider()

                            Button(
                                action: cancelAction,
                                label: {
                                    Text("Cancel")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppColor.text)
                                        .padding(AppDimens.padding16)
                                        .frame(maxWidth: .infinity)
                                }
                            )
                            .foregroundColor(.black)
                        }
                        .fixedSize()
                        .background(.thinMaterial)
                        .cornerRadius(20)

                        Spacer()
                    }
                }
                .colorScheme(.dark)
            }
        }
        .animation(.default, value: isPresented)
    }
}

#Preview {
    ZStack {
        AppColor.backgroundGradient
            .ignoresSafeArea()

        DeviceConnectionModal(
            isPresented: true,
            deviceName: "TEST DEVICE",
            cancelAction: {}
        )
    }
}
