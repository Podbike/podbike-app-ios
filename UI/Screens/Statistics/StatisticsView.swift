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
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        StatisticsEntry(
                            value: viewModel.temperatureValue,
                            unit: viewModel.temperatureUnit,
                            label: "StatisticTemperature"
                        )

                        StatisticsEntry(
                            value: viewModel.averageRpmValue,
                            unit: "rpm",
                            label: "StatisticAverageCadence"
                        )

                        StatisticsEntry(
                            value: viewModel.co2Value,
                            unit: "kg",
                            label: "StatisticCO2"
                        )

                        StatisticsEntry(
                            value: viewModel.totalDistanceValue,
                            unit: viewModel.totalDistanceUnit,
                            label: "StatisticTotalDistance"
                        )

                        StatisticsEntry(
                            value: viewModel.averageTotalSpeedValue,
                            unit: viewModel.speedUnit,
                            label: "StatisticAverageTotalSpeed"
                        )
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 0) {
                        StatisticsEntry(
                            value: viewModel.batteryPercentValue,
                            unit: "%",
                            label: "StatisticBattery"
                        )

                        StatisticsEntry(
                            value: viewModel.generatedPowerValue,
                            unit: "W",
                            label: "StatisticPower"
                        )

                        StatisticsEntry(
                            value: viewModel.maxTripSpeedValue,
                            unit: viewModel.speedUnit,
                            label: "StatisticMaxTripSpeed"
                        )

                        StatisticsEntry(
                            value: viewModel.tripTimeValue,
                            unit: "min",
                            label: "StatisticTime"
                        )

                        StatisticsEntry(
                            value: viewModel.averageTripSpeedValue,
                            unit: viewModel.speedUnit,
                            label: "StatisticAverageTripSpeed"
                        )
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer()

                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 42)
            }
            .padding(.horizontal, AppDimens.padding32)
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
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(unit)
                    .font(.custom(AppFont.appFont, size: 26))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
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
