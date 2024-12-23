import SwiftUI

// MARK: DashboardView

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    @State var tooltipView: AnyView? = nil

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
                    let topRowHeight = 64.0
                    ZStack {
                        if viewModel.isRidingMode || viewModel.isHelpMode {
                            WarningIcons(viewModel: viewModel, rowHeight: topRowHeight, tooltipView: $tooltipView)
                        } else {
                            TopButtons(viewModel: viewModel, rowHeight: topRowHeight)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .frame(height: topRowHeight)
                    .animation(.default, value: viewModel.isRidingMode)

                    Spacer()

                    let speedFontSize = geometry.size.height / 3
                    ZStack {
                        let showSpeed = (
                            viewModel.isBluetoothOn && viewModel.isBikeOn == true
                        ) || viewModel.isHelpMode

                        Text(viewModel.speedText)
                            .font(Font.custom(AppFont.appFont, size: speedFontSize))
                            .fixedSize()
                            .padding(.vertical, -speedFontSize / 5)
                            .opacity(showSpeed ? 1 : 0)
                            .speedometerTooltip($tooltipView, speedUnit: viewModel.speedUnit)

                        if !showSpeed {
                            if !viewModel.isBluetoothOn {
                                Button(
                                    "DeviceBluetoothOn",
                                    action: viewModel.showBleEnablePrompt
                                )
                                .buttonStyle(AppButton.alert)
                            } else if viewModel.isFirmwareUpdateInProgress {
                                Text("UpdateUpgradeInfoDashboard").headline
                                    .padding(.horizontal, AppDimens.padding16)
                                    .padding(.bottom, AppDimens.padding48)
                            } else if viewModel.isBikeOn == false {
                                Text("FrikarIsOff").headline
                            }
                        }
                    }

                    Spacer()

                    RangeAndBattery(viewModel: viewModel)
                        .batteryAndRangeTooltip($tooltipView, distanceUnit: viewModel.distanceUnit)

                    Spacer()

                    HStack {
                        TotalDistance(viewModel: viewModel)
                            .odometerTooltip($tooltipView, distanceUnit: viewModel.distanceUnit)
                        Spacer()
                        ModeAndLights(viewModel: viewModel)
                            .modeAndLightsTooltip($tooltipView)
                    }
                    .padding(.horizontal, horizontalPadding)

                    Spacer()

                    AssistanceLevel(viewModel: viewModel)
                        .assistanceTooltip($tooltipView)
                        .padding(.horizontal, horizontalPadding)

                    Spacer()

                    CadenceLevel(viewModel: viewModel)
                        .cadenceTooltip($tooltipView)
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, -8)

                    Spacer()
                }
                .padding(.vertical, AppDimens.padding16)

#if DEBUG
                if !viewModel.isHelpMode {
                    ConnectionDebugInfo(viewModel: viewModel)
                }
#endif

                HelpReturnButton(viewModel: viewModel)
                    .padding(.bottom, -geometry.safeAreaInsets.bottom / 3)
            }
            .navigationBarBackButtonHidden()
            .colorScheme(.dark)
            .onAppear {
                disableScreenSleep()
                if viewModel.connectedDevice == nil {
                    viewModel.reconnect()
                }
            }
            .alert("UpdateComplete", isPresented: $viewModel.showFirmwareUpdateCompleted) {}
            .alert("UpdateFailed", isPresented: $viewModel.showFirmwareUpdateFailed) {}
            .onTapGesture {
                viewModel.isHelpMode = false
            }

            HelpInfoModal(isPresented: viewModel.isShowingHelpInfo) {
                viewModel.isShowingHelpInfo = false
                tooltipView = nil
                viewModel.isHelpMode = true
            }
            .padding(.top, 90)

            if viewModel.isHelpMode {
                tooltipView
            }

            DashboardTurnIndicator(viewModel: viewModel)
            DashboardHazardIndicator(viewModel: viewModel)
        }
    }

    private func disableScreenSleep() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
}

// MARK: RangeAndBattery

private struct RangeAndBattery: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            let batteryPercent = viewModel.batteryPercent
            let screenHeight = UIScreen.height
            let barHeight = max(56, min(screenHeight / 11, 64))

            Rectangle()
                .fill(AppColor.indicatorBackground)
                .overlay(alignment: .leading) {
                    let barWidth = UIScreen.width * CGFloat(batteryPercent) / 100

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
                .frame(height: barHeight)

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

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(distance + " ")
                    .font(.custom(AppFont.appBoldFont, size: 48))
                    .foregroundColor(AppColor.text)
                    .lineLimit(1)

                Text(unit)
                    .font(.custom(AppFont.appBoldFont, size: 25))
                    .foregroundColor(AppColor.text)
            }
            .minimumScaleFactor(0.3)
        }
    }
}

// MARK: ModeAndLights

private struct ModeAndLights: View {
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
        let screenWidth = UIScreen.width
        let rectSize = min(screenWidth / 7, 52)
        let elementNegativePadding = rectSize / 4
        let shapePadding = rectSize / 2 * (sqrt(2) - 1)
        let horizontalPadding = AppDimens.padding8 + shapePadding + elementNegativePadding
        let cornerRadius = 5.0

        let levels = 9
        let selectedLevel = viewModel.cadenceLevel

        HStack(spacing: 0) {
            ForEach(1 ... levels, id: \.self) { level in
                let levelIsOn = level <= selectedLevel
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        levelIsOn ? AppColor.accent : AppColor.indicatorBackground
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.black, lineWidth: 1)
                    )
                    .frame(width: rectSize, height: rectSize)
                    .rotationEffect(.degrees(45))
                    .padding(.horizontal, -elementNegativePadding)

                if level != levels {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, shapePadding)
    }
}

// MARK: TopButtons

private struct ConnectionDebugInfo: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            if let connectedDevice = viewModel.connectedDevice {
                Text("Connected to: \(connectedDevice.deviceName)").label
            } else {
                Text("Disconnected")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.alert)
            }
        }
        .padding(.top, -AppDimens.padding16)
    }
}

// MARK: HelpReturnButton

private struct HelpReturnButton: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            if viewModel.isHelpMode {
                Button(
                    action: { viewModel.isHelpMode = false },
                    label: {
                        Text("HelpReturnButton")
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .font(AppFont.strong)
                    }
                )
                .buttonStyle(AppButton.dark)
                .shadow(color: Color.black, radius: 10)
                .transition(.slide)
            }
        }
        .animation(.easeOut, value: viewModel.isHelpMode)
    }
}

// MARK: Preview - Dashboard

#Preview {
    DashboardServiceLocator.instance.provideDashboardView(coordinator: DashboardCoordinatorViewModel(parentCoordinator: nil))
}
