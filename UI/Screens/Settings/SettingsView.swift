import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }

    @State private var showSpeedPicker = false
    @State private var showDistancePicker = false
    @State private var showTemperaturePicker = false

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            List {
                SettingsHeader("SettingsGeneral") {
                    SettingsRow("SettingsLanguage", viewModel.onLanguageTapped)
                    SettingsRow("SettingsDevices", viewModel.onDevicesTapped)
                    SettingsRow("SettingsUpdate", viewModel.onFirmwareUpdateTapped)
                }

                SettingsHeader("SettingsUnits") {
                    SettingsRow("SettingsSpeedUnit") {
                        hidePickers()
                        withAnimation {
                            showSpeedPicker = true
                        }
                    }
                    SettingsRow("SettingsDistanceUnit") {
                        hidePickers()
                        withAnimation {
                            showDistancePicker = true
                        }
                    }
                    SettingsRow("SettingsTemperatureUnit") {
                        hidePickers()
                        withAnimation {
                            showTemperaturePicker = true
                        }
                    }
                }
                SettingsHeader("SettingsAbout") {
                    SettingsRow("SettingsFrikar", viewModel.onFrikarInfoTapped)
                    SettingsRow("SettingsPolicies", viewModel.onPoliciesTapped)
                }

                AppVersionRow()
            }
            .listStyle(.grouped)
            .padding(.top, AppDimens.padding16)
            .transparentListBackground()

            BottomWheelPicker(
                isPresented: $showSpeedPicker,
                label: "SettingsSelectUnit",
                entries: [
                    SpeedUnit.kilometersPerHour,
                    SpeedUnit.milesPerHour,
                    SpeedUnit.metersPerSecond,
                ],
                selection: $viewModel.speedUnit
            )

            BottomWheelPicker(
                isPresented: $showDistancePicker,
                label: "SettingsSelectUnit",
                entries: [
                    DistanceUnit.kilometers,
                    DistanceUnit.miles,
                    DistanceUnit.meters,
                ],
                selection: $viewModel.distanceUnit
            )

            BottomWheelPicker(
                isPresented: $showTemperaturePicker,
                label: "SettingsSelectUnit",
                entries: [
                    TemperatureUnit.celsius,
                    TemperatureUnit.fahrenheit,
                ],
                selection: $viewModel.temperatureUnit
            )
        }
        .toolbar(
            title: "SettingsPageTitle",
            onBack: viewModel.dismiss
        )
    }

    private func hidePickers() {
        showSpeedPicker = false
        showDistancePicker = false
        showTemperaturePicker = false
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

    @State var isHighlighted = false

    init(_ text: LocalizedStringKey, _ action: @escaping @MainActor () -> Void) {
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
            .buttonStyle(RowButtonStyle(isHighlighted: isHighlighted))
            .simultaneousGesture(TapGesture().onEnded {
                isHighlighted = true
                DispatchQueue.main.async {
                    withAnimation {
                        isHighlighted = false
                    }
                }
            })

            AppColor.dimGray
                .frame(height: 1)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(
            .init(top: 0, leading: AppDimens.padding16, bottom: -1, trailing: AppDimens.padding16)
        )
    }

    private struct RowButtonStyle: ButtonStyle {

        let isHighlighted: Bool

        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .background((configuration.isPressed || isHighlighted) ? AppColor.dimGray : Color.clear)
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

#Preview {
    SettingsServiceLocator.instance.provideSettingsView(coordinator: SettingsCoordinatorViewModel(parentCoordinator: nil))
}
