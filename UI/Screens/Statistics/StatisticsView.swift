import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppColor.backgroundGradient
                .ignoresSafeArea()

            VStack {
                Spacer()
                
                HStack(spacing: AppDimens.padding32) {
                    VStack(spacing: 0) {
                        StatisticsEntry(
                            value: viewModel.temperatureValue,
                            unit: viewModel.temperatureUnit,
                            label: "StatisticTemperature"
                        )

                        StatisticsEntry(
                            value: viewModel.totalDistanceValue,
                            unit: viewModel.totalDistanceUnit,
                            label: "StatisticTotalDistance"
                        )

                        StatisticsEntry(
                            value: viewModel.averageSpeedValue,
                            unit: viewModel.averageSpeedUnit,
                            label: "StatisticAverageSpeed"
                        )

                        StatisticsEntry(
                            value: viewModel.generatedPowerValue,
                            unit: "W",
                            label: "StatisticPower"
                        )
                    }

                    VStack(spacing: 0) {
                        StatisticsEntry(
                            value: viewModel.co2Value,
                            unit: "kg",
                            label: "StatisticCO2"
                        )

                        StatisticsEntry(
                            value: viewModel.tripTimeValue,
                            unit: "min",
                            label: "StatisticTime"
                        )

                        StatisticsEntry(
                            value: viewModel.averageRpmValue,
                            unit: "rpm",
                            label: "StatisticAverageCadence"
                        )

                        StatisticsEntry(
                            value: viewModel.batteryPercentValue,
                            unit: "%",
                            label: "StatisticBattery"
                        )
                    }
                }

                Spacer()

                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 42)
            }
            .padding(.horizontal, AppDimens.padding16)
            .padding(.bottom, AppDimens.padding32)
        }
        .toolbar(
            title: "StatisticsPageTitle",
            onBack: viewModel.dismiss
        )
    }
}

private struct StatisticsEntry: View {
    var value: String
    var unit: String
    var label: LocalizedStringKey

    init(value: String, unit: String, label: LocalizedStringKey) {
        self.value = value
        self.unit = unit
        self.label = label
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.custom(AppFont.appFont, size: 28).bold())

                Text(unit)
                    .font(.custom(AppFont.appFont, size: 26))
            }

            Text(label)
                .font(AppFont.micro)
                .multilineTextAlignment(.center)
                .frame(minHeight: 48, alignment: .top)
                .padding(0)
        }
    }
}

#Preview {
    StatisticsServiceLocator.instance.provideStatisticsView(coordinator: nil)
}
