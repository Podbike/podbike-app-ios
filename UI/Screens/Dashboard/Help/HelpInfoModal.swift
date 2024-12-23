import SwiftUI

public struct HelpInfoModal: View {
    private let isPresented: Bool
    private let action: () -> Void

    public init(isPresented: Bool, action: @escaping () -> Void) {
        self.isPresented = isPresented
        self.action = action
    }

    public var body: some View {
        ZStack {
            if isPresented {
                ZStack {
                    VStack(spacing: 0) {
                        let text = String(localized: "HelpInfoModal")
                        let textComponents = text.split(maxSplits: 1, whereSeparator: \.isNewline)
                        let title = textComponents.first ?? ""
                        let description = textComponents.last ?? ""

                        Text(title)
                            .font(AppFont.strong)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.center)

                        AppSpacers.h24

                        Text(description)
                            .font(AppFont.label)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.center)

                        AppSpacers.h32

                        Button(
                            action: action,
                            label: {
                                Text("OK")
                                    .frame(height: AppButton.buttonHeight)
                                    .font(AppFont.strongBody)
                            }
                        )
                        .buttonStyle(AppButton.dark)
                    }
                    .padding(AppDimens.padding24)
                }
                .background(.ultraThickMaterial)
                .colorScheme(.light)
                .cornerRadius(8)
                .transition(
                    .scale(scale: 0, anchor: .topLeading).combined(with: .opacity)
                )
            }
        }
        .padding(.horizontal, AppDimens.padding48)
        .animation(.bouncy(duration: 0.3), value: isPresented)
        .shadow(color: Color.black, radius: 20, x: 0, y: 20)
    }
}

#Preview {
    ZStack {
        AppColor.backgroundGradient
            .ignoresSafeArea()

        HelpInfoModal(
            isPresented: true,
            action: {}
        )
    }
}
