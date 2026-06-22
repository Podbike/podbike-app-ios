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

struct PoliciesView: View {
    @ObservedObject var viewModel: PoliciesViewModel

    init(viewModel: PoliciesViewModel) {
        self.viewModel = viewModel
    }

    @State var selectedTab: String = "PolicyPrivacy"

    var body: some View {
        let body =
            TabView(selection: $selectedTab) {
                PolicyTab(
                    htmlContent: viewModel.privacyPolicyHtml,
                    furtherInfo: viewModel.privacyFutherInfo
                )
                .tabItem {
                    Text("PolicyPrivacy")

                    AppIcon.privacyPolicy
                        .size(24)
                        .toImage()
                }
                .tag("PolicyPrivacy")

                PolicyTab(
                    htmlContent: viewModel.termsAndConditionsHtml,
                    furtherInfo: viewModel.termsFutherInfo
                )
                .tabItem {
                    Text("PolicyTermsConditions")

                    AppIcon.termsAndConditions
                        .size(24)
                        .toImage()
                }
                .tag("PolicyTermsConditions")
            }
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            .toolbar(
                title: LocalizedStringKey(selectedTab),
                onBack: viewModel.dismiss
            )
            .colorScheme(.dark)

        if #available(iOS 16.0, *) {
            return body.toolbarBackground(.visible, for: .navigationBar)
        }

        return body
    }
}

struct PolicyTab: View {
    private let htmlContent: String
    private let furtherInfo: String?

    init(htmlContent: String, furtherInfo: String?) {
        self.htmlContent = htmlContent
        self.furtherInfo = furtherInfo
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(styledHtml(htmlContent))

                if let furtherInfo {
                    Text(.init(furtherInfo))
                        .font(AppFont.label)
                        .foregroundStyle(AppColor.text)
                        .accentColor(Color(uiColor: .link))
                }
            }
            .padding(.horizontal, AppDimens.padding16)
            .padding(.vertical, AppDimens.padding32)
        }
    }

    private func styledHtml(_ html: String) -> AttributedString {
        let htmlStyle = "<span style=\"font-family: '\(AppFont.appFont)'; font-size: 18\">"
        let html = htmlStyle + html
            .replacingOccurrences(of: "</p>", with: "</p><br/>")

        guard let nsAttributedString = try? NSAttributedString(data: Data(html.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else { return "" }

        guard var attributedString = try? AttributedString(nsAttributedString, including: \.uiKit) else {
            return ""
        }

        attributedString.foregroundColor = AppColor.text
        return attributedString
    }
}

#Preview {
    PoliciesServiceLocator.instance.providePoliciesView(coordinator: nil)
}
