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

enum AppFont {
    static let appFont = "Poppins-Regular"
    static let appBoldFont = "Poppins-Bold"

    static let body: Font = .custom(appFont, size: 16)
    static let strongBody: Font = .custom(appBoldFont, size: 16)
    static let label: Font = .custom(appFont, size: 18)
    static let info: Font = .custom(appFont, size: 20)
    static let title: Font = .custom(appBoldFont, size: 18)
    static let strong: Font = .custom(appBoldFont, size: 20)
    static let large: Font = .title
    static let small: Font = .subheadline
    static let micro: Font = .custom(appFont, size: 14)
    static let headline: Font = .system(size: 24).bold()
    static let pageTitle: Font = .custom(appBoldFont, size: 36)
    static let alert: Font = .custom(appBoldFont, size: 24)

}

extension Text {
    var body: some View { modifier(BodyText()) }
    var label: some View { modifier(LabelText()) }
    var info: some View { modifier(InfoText()) }
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
                .minimumScaleFactor(0.4)
                .lineLimit(1)
        }
    }

    struct AlertText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.alert)
                .foregroundColor(AppColor.text)
                .minimumScaleFactor(0.7)
        }
    }

    struct InfoText: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(AppFont.info)
                .foregroundColor(AppColor.text)
                .minimumScaleFactor(0.7)
        }
    }
}
