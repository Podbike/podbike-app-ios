import SwiftUI

enum AppFont {
    private static let appFont = "Poppins-Regular"
    private static let appBoldFont = "Poppins-Bold"

    static let body: Font = .custom(appFont, size: 16)
    static let label: Font = .custom(appFont, size: 18)
    static let title: Font = .custom(appBoldFont, size: 18)
    static let headline: Font = .system(size: 24).bold()
    static let pageTitle: Font = .custom(appBoldFont, size: 36)
}

extension Text {
    var body: some View { modifier(BodyText()) }
    var label: some View { modifier(LabelText()) }
    var title: some View { modifier(TitleText()) }
    var headline: some View { modifier(HeadlineText()) }
    var pageTitle: some View { modifier(PageTitleText()) }

    struct BodyText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.body)
                .foregroundColor(AppColor.text)
                .minimumScaleFactor(0.7)
        }
    }

    struct LabelText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.label)
                .foregroundColor(AppColor.text)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
    }

    struct TitleText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.title)
                .foregroundColor(AppColor.text)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
    }

    struct HeadlineText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.headline)
                .foregroundColor(AppColor.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)
        }
    }

    struct PageTitleText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.pageTitle)
                .foregroundColor(AppColor.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
    }
}
