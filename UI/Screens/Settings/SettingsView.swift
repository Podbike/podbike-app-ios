import SwiftUI

typealias Key = LocalizedStringKey

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            List {
                SettingsHeader(Key("SettingsGeneral")) {
                    SettingsRow(Key("SettingsLanguage"), action: onLanguageTapped)
                    SettingsRow(Key("SettingsDevices")) {}
                    SettingsRow(Key("SettingsUpdate")) {}
                }

                SettingsHeader(Key("SettingsUnits")) {
                    SettingsRow(Key("SettingsSpeedUnit")) {}
                    SettingsRow(Key("SettingsDistanceUnit")) {}
                    SettingsRow(Key("SettingsTemperatureUnit")) {}
                }
                SettingsHeader(Key("SettingsAbout")) {
                    SettingsRow(Key("SettingsFrikar")) {}
                    SettingsRow(Key("SettingsPolicies")) {}
                }

                AppVersionRow()
            }
            .listStyle(.grouped)
            .padding(.top, AppDimens.padding16)
            .transparentBackground()
        }
        .toolbar(
            title: LocalizedStringKey("SettingsPageTitle"),
            onBack: viewModel.dismiss
        )
    }

    func onLanguageTapped() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsHeader<Content: View>: View {
    private let text: LocalizedStringKey
    let content: () -> Content

    init(
        _ text: LocalizedStringKey,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.text = text
        self.content = content
    }

    var body: some View {
        Section(
            header: Text(text)
                .font(AppFont.title)
                .foregroundColor(AppColor.text),
            content: content
        )
    }
}

struct SettingsRow: View {
    private let text: LocalizedStringKey
    private let action: () -> Void

    init(_ text: LocalizedStringKey, action: @escaping @MainActor () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        VStack(spacing: 0) {
            AppColor.dimGray
                .frame(height: 1)

            Button(action: action) {
                HStack {
                    AppSpacers.w16

                    Text(text)
                        .font(AppFont.label)
                        .foregroundColor(AppColor.text)

                    Spacer()

                    AppIcon.chevronRight
                        .size(36)
                        .foregroundStyle(AppColor.white)
                }
                .padding(.vertical, AppDimens.padding8)
            }
            .buttonStyle(RowButtonStyle())

            AppColor.dimGray
                .frame(height: 1)
        }
        .listRowBackground(Color.clear)
        .listItemTint(.accent)
        .listRowSeparator(.hidden)
        .listRowInsets(
            .init(top: 0, leading: AppDimens.padding16, bottom: -1, trailing: AppDimens.padding16)
        )
    }

    private struct RowButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .background(configuration.isPressed ? AppColor.dimGray : Color.clear)
                .contentShape(Rectangle())
        }
    }
}

struct AppVersionRow: View {
    var body: some View {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        Text(String(localized: "SettingsAppVersion") + " \(appVersion ?? "")").label
            .centerHorizontally()
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

private extension View {
    @ViewBuilder
    func transparentBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            background(Color.clear)
        }
    }
}

#Preview {
    SettingsServiceLocator.instance.provideSettingsView(coordinator: RootCoordinatorViewModel(parentCoordinator: nil))
}
