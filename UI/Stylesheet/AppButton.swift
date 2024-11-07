import SwiftUI

enum AppButton {
    static let primary = PrimaryButton()
    static let secondary = SecondaryButton()

    struct PrimaryButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 200, height: 55)
                .background(
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    )
                    .fill(AppColor.accent)
                )
                .opacity(configuration.isPressed ? 0.7 : 1)
                .foregroundStyle(AppColor.text)
                .font(AppFont.body)
        }
    }

    struct SecondaryButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 200, height: 55)
                .opacity(configuration.isPressed ? 0.7 : 1)
                .foregroundStyle(AppColor.text)
                .font(AppFont.body)
        }
    }
}
