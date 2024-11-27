import SwiftUI

private let topRowHeight = 64.0

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColor.backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ZStack {
                        if viewModel.isRideMode {
                            WarningIcons(viewModel: viewModel)
                        } else {
                            TopButtons(viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, AppDimens.padding16)

                    let speedFontSize = sqrt(geometry.size.width * geometry.size.height) * 0.45
                    Text(viewModel.speedText)
                        .font(Font.custom(AppFont.appFont, size: speedFontSize))
                        .fixedSize()
                        .padding(.top, -speedFontSize / 10)

                    RangeAndBattery(viewModel: viewModel)

                    AppSpacers.h32

                    HStack {
                        TripDistance(viewModel: viewModel)
                        Spacer()
                        ModeIcons(viewModel: viewModel)
                    }
                    .padding(.horizontal, AppDimens.padding16)

                    Spacer()

                    if let connectedDevice = viewModel.connectedDevice {
                        Text("Connected to:\n\(connectedDevice.deviceName)").label
                    } else {
                        Text("Disconnected")
                            .font(AppFont.title)
                            .foregroundStyle(AppColor.alert)
                    }

                    Spacer()
                }
                .padding(.vertical, AppDimens.padding16)
            }
            .navigationBarBackButtonHidden()
            .colorScheme(.dark)
            .onAppear {
                if viewModel.connectedDevice == nil {
                    viewModel.reconnect()
                }
            }
        }
    }
}

private struct WarningIcons: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        let inactiveOpacity = 0.25
        GeometryReader { geometry in
            HStack {
                let iconSize = min(geometry.size.width / 6, topRowHeight)
                AppIcon.snowAlert.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.tractionControl.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.lightAlert.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.tireAlert.size(iconSize).opacity(inactiveOpacity)
                Spacer()
                AppIcon.brakeAlert.size(iconSize).opacity(inactiveOpacity)
            }
        }
        .frame(height: topRowHeight)
    }
}

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

private struct RangeAndBattery: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            let batteryPercent = viewModel.batteryPercent
            GeometryReader { geometry in
                Rectangle()
                    .fill(AppColor.tertiary)
                    .overlay(alignment: .leading) {
                        let barWidth = geometry.size.width * CGFloat(batteryPercent) / 100

                        if batteryPercent <= 30 {
                            Rectangle().fill(Color.red)
                                .frame(width: barWidth)
                        } else {
                            let gradient = LinearGradient(
                                gradient: Gradient(colors: [Color(hex: 0x44D62C), Color(hex: 0x3BAC28)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            Rectangle().fill(gradient)
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

private struct TripDistance: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        HStack {
            let distanceAndUnit = viewModel.tripDistanceText.components(separatedBy: .whitespaces)
            let distance = distanceAndUnit[0]
            let unit = distanceAndUnit.count >= 2 ? distanceAndUnit[1] : ""
            Text(distance + " ")
                .font(.custom(AppFont.appBoldFont, size: 48))
                .foregroundColor(AppColor.text)
            + Text(unit)
                .font(.custom(AppFont.appBoldFont, size: 25))
                .foregroundColor(AppColor.text)
        }
    }
}

private struct ModeIcons: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        HStack {
            let iconSize = 48.0
            AppIcon.bluetoothOff.size(iconSize)
            if viewModel.highBeam {
                AppIcon.highBeam
                    .size(iconSize)
                    .foregroundStyle(Color(hex: 0x2196F3))
            } else {
                AppIcon.carLights
                    .size(iconSize)
            }

        }
    }
}

#Preview {
    DashboardServiceLocator.instance.provideDashboardView(coordinator: DashboardCoordinatorViewModel(parentCoordinator: nil))
}
