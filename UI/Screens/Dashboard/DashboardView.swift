import SwiftUI

private let topRowHeight = 64.0

// MARK: DashboardView

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                AppColor.backgroundGradient
                    .ignoresSafeArea()

                let horizontalPadding = AppDimens.padding16

                VStack(spacing: 0) {
                    ZStack {
                        if viewModel.isRidingMode {
                            WarningIcons(viewModel: viewModel)
                        } else {
                            TopButtons(viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .frame(height: topRowHeight)
                    .animation(.default, value: viewModel.isRidingMode)

                    let speedFontSize = sqrt(geometry.size.width * geometry.size.height) * 0.45
                    ZStack {
                        Text(viewModel.speedText)
                            .font(Font.custom(AppFont.appFont, size: speedFontSize))
                            .fixedSize()
                            .padding(.top, -speedFontSize / 10)
                            .opacity(viewModel.isBluetoothOn && viewModel.isBikeOn ? 1 : 0)

                        if !viewModel.isBluetoothOn {
                            Button(
                                "DeviceBluetoothOn",
                                action: viewModel.showBleEnablePrompt
                            )
                            .buttonStyle(AppButton.alert)
                        } else if (!viewModel.isBikeOn) {
                            Text("FrikarIsOff")
                                .headline
                        }
                    }

                    RangeAndBattery(viewModel: viewModel)
                        .padding(.top, -speedFontSize / 10)

                    AppSpacers.h32

                    HStack {
                        TotalDistance(viewModel: viewModel)
                        Spacer()
                        ModeIcons(viewModel: viewModel)
                    }
                    .padding(.horizontal, horizontalPadding)

                    AppSpacers.h32

                    AssistanceLevel(viewModel: viewModel)
                        .padding(.horizontal, horizontalPadding)

                    AppSpacers.h(36)

                    CadenceLevel(viewModel: viewModel)
                        .padding(.horizontal, horizontalPadding)

                    Spacer()
                }
                .padding(.vertical, AppDimens.padding16)

                // TODO: - temporary debug info
                ZStack {
                    if let connectedDevice = viewModel.connectedDevice {
                        Text("Connected to: \(connectedDevice.deviceName)").label
                    } else {
                        Text("Disconnected")
                            .font(AppFont.title)
                            .foregroundStyle(AppColor.alert)
                    }
                }
                .padding(.vertical, -AppDimens.padding16)
            }
            .navigationBarBackButtonHidden()
            .colorScheme(.dark)
            .onAppear {
                if viewModel.connectedDevice == nil {
                    viewModel.reconnect()
                }
            }

            DashboardTurnIndicator(viewModel: viewModel)
            DashboardHazardIndicator(viewModel: viewModel)
        }
    }
}

// MARK: WarningIcons

private struct WarningIcons: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        let inactiveOpacity = 0.25
        GeometryReader { geometry in
            let iconSize = min(geometry.size.width / 6, topRowHeight)
            HStack {
                AppIcon.snowAlert.size(iconSize)
                    .opacity(viewModel.isIceWarning ? 1 : inactiveOpacity)
                Spacer()
                AppIcon.tractionControl.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.lightAlert.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.tireAlert.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.brakeAlert.size(iconSize)
                    .opacity(viewModel.isBrakeLight ? 1 : inactiveOpacity)
            }
        }
    }
}

// MARK: TopButtons

private struct TopButtons: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        HStack {
            Button(action: viewModel.goToDebugHomeScreen) {
                AppIcon.help.size(topRowHeight).foregroundStyle(AppColor.white)
            }

            Spacer()

            Button(action: {}) {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 42)
            }

            Spacer()

            Button(action: viewModel.goToSettingsScreen) {
                AppIcon.settings.size(topRowHeight).foregroundStyle(AppColor.white)
            }
        }
    }
}

// MARK: RangeAndBattery

private struct RangeAndBattery: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            let batteryPercent = viewModel.batteryPercent
            GeometryReader { geometry in
                Rectangle()
                    .fill(AppColor.indicatorBackground)
                    .overlay(alignment: .leading) {
                        let barWidth = geometry.size.width * CGFloat(batteryPercent) / 100

                        if batteryPercent <= 30 {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: barWidth)
                        } else {
                            let gradient = LinearGradient(
                                gradient: Gradient(colors: [AppColor.accent, AppColor.dimAccent]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            Rectangle()
                                .fill(gradient)
                                .frame(width: barWidth)
                        }
                    }
            }
            .frame(height: 64)

            Text(viewModel.rangeText)
                .font(.custom(AppFont.appBoldFont, size: 42))
                .foregroundStyle(AppColor.quaternary)
        }
    }
}

// MARK: TotalDistance

private struct TotalDistance: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        HStack {
            var components = viewModel.totalDistanceText.components(separatedBy: .whitespaces)
            let unit = components.removeLast()
            let distance = components.joined(separator: " ")

            Text(distance + " ")
                .font(.custom(AppFont.appBoldFont, size: 48))
                .foregroundColor(AppColor.text)
                + Text(unit)
                .font(.custom(AppFont.appBoldFont, size: 25))
                .foregroundColor(AppColor.text)
        }
    }
}

// MARK: ModeIcons

private struct ModeIcons: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        let iconSize = 48.0
        HStack {
            if viewModel.connectedDevice == nil {
                AppIcon.bluetoothOff.size(iconSize)
            }

            if viewModel.isHighBeam {
                AppIcon.highBeam
                    .size(iconSize)
                    .foregroundStyle(Color(hex: 0x2196F3))
            } else if viewModel.isLowBeam {
                AppIcon.carLights
                    .size(iconSize)
            }
        }
    }
}

// MARK: AssistanceLevel

private struct AssistanceLevel: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        let circleSize = 64.0
        let levels = 5
        let selectedLevel = viewModel.assistanceLevel / 20

        HStack(spacing: 8) {
            ForEach(1 ... levels, id: \.self) { level in
                let levelIsOn = level <= selectedLevel
                Circle()
                    .frame(height: circleSize)
                    .foregroundStyle(
                        levelIsOn ? AppColor.accent : AppColor.indicatorBackground
                    )

                if level != levels {
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: CadenceLevel

private struct CadenceLevel: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        let rectSize = 52.0
        let elementNegativePadding = rectSize / 4
        let shapePadding = rectSize / 2 * (sqrt(2) - 1)
        let horizontalPadding = AppDimens.padding8 + shapePadding + elementNegativePadding

        let levels = 9
        let selectedLevel = viewModel.cadenceLevel

        HStack(spacing: 0) {
            AppSpacers.w(horizontalPadding)

            ForEach(1 ... levels, id: \.self) { level in
                let levelIsOn = level <= selectedLevel
                Rectangle()
                    .frame(width: rectSize, height: rectSize)
                    .foregroundStyle(
                        levelIsOn ? AppColor.accent : AppColor.indicatorBackground
                    )
                    .border(.black, width: 1)
                    .rotationEffect(.degrees(45))
                    .padding(.horizontal, -elementNegativePadding)

                if level != levels {
                    Spacer(minLength: 0)
                }
            }

            AppSpacers.w(horizontalPadding)
        }
    }
}

#Preview {
    DashboardServiceLocator.instance.provideDashboardView(coordinator: DashboardCoordinatorViewModel(parentCoordinator: nil))
}
