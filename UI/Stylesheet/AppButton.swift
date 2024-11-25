import SwiftUI

enum AppButton {
    static let primary = PrimaryButton()
    static let primaryProminent = PrimaryButton(prominent: true)
    static let secondary = SecondaryButton()
    static let alert = AlertButton()

    struct PrimaryButton: ButtonStyle {
        var prominent = false

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
}
