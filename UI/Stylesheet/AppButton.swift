import SwiftUI

enum AppButton {
    static let primary = PrimaryButton()
    static let primaryProminent = PrimaryButton(prominent: true)
    static let primaryTall = PrimaryButton(height: 80)
    static let secondary = SecondaryButton()

    struct PrimaryButton: ButtonStyle {
        var prominent = false
        var height = 55.0

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: 200, height: height)
                .background(
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    )
                    .fill(AppColor.accent)
                )
                .opacity(configuration.isPressed ? 0.7 : 1)
                .foregroundStyle(AppColor.text)
                .font(prominent ? AppFont.title : AppFont.label)
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
