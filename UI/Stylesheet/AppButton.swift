import SwiftUI

enum AppButton {
    static let primary = PrimaryButton()
    static let primaryProminent = PrimaryButton(prominent: true)
    static let secondary = SecondaryButton()
    static let alert = AlertButton()
    static let dark = DarkButton()

    static let buttonWidth = 200.0
    static let buttonHeight = 55.0

    struct PrimaryButton: ButtonStyle {
        var prominent = false

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(width: buttonWidth, height: buttonHeight)
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
                .frame(width: buttonWidth, height: buttonHeight)
                .opacity(configuration.isPressed ? 0.7 : 1)
                .foregroundStyle(AppColor.text)
                .font(AppFont.body)
        }
    }

    struct AlertButton: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(AppDimens.padding16)
                .background(
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    )
                    .fill(AppColor.alert)
                )
                .opacity(configuration.isPressed ? 0.7 : 1)
                .foregroundStyle(AppColor.text)
                .font(AppFont.alert)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
        }
    }

    struct DarkButton: ButtonStyle {
        var prominent = false

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, AppDimens.padding32)
                .background(
                    RoundedRectangle(
                        cornerRadius: 5,
                        style: .continuous
                    )
                    .fill(AppColor.darkButton)
                )
                .opacity(configuration.isPressed ? 0.7 : 1)
                .foregroundStyle(AppColor.text)
        }
    }
}
