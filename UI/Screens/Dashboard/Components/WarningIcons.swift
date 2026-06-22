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

struct WarningIcons: View {
    @ObservedObject var viewModel: DashboardViewModel
    let rowHeight: Double
    let tooltipView: Binding<AnyView?>

    var body: some View {
        let inactiveOpacity = 0.25
        GeometryReader { geometry in
            let iconSize = min(geometry.size.width / 6, self.rowHeight)
            HStack {
                AppIcon.snowAlert.size(iconSize)
                    .opacity(self.viewModel.isSnowAlert ? 1 : inactiveOpacity)
                    .snowAlertTooltip(tooltipView, alertThreshold: self.viewModel.snowAlertThresholdText)

                Spacer()

                AppIcon.tractionControl.size(iconSize)
                    .opacity(inactiveOpacity) // not supported in this version
                    .tractionControlTooltip(tooltipView)

                Spacer()

                AppIcon.lightAlert.size(iconSize)
                    .opacity(inactiveOpacity) // not supported in this version
                    .lightAlertTooltip(tooltipView)

                Spacer()

                AppIcon.tireAlert.size(iconSize)
                    .opacity(inactiveOpacity) // not supported in this version
                    .tireAlertTooltip(tooltipView)

                Spacer()

                AppIcon.brakeAlert.size(iconSize)
                    .opacity(self.viewModel.isBrakeLight ? 1 : inactiveOpacity)
                    .brakeAlertTooltip(tooltipView)
            }
            .frame(height: geometry.size.height)
        }
    }
}

// MARK: Help Tooltips

private extension View {
    func snowAlertTooltip(_ tooltipView: Binding<AnyView?>, alertThreshold: String) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(format: String(localized: "HelpSnowAlert"), alertThreshold),
            arrow: UnitPoint(x: 0.1, y: 0),
            isPresented: tooltipView.wrappedValue == nil
        )
    }

    func tractionControlTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpTractionControl"),
            arrow: UnitPoint(x: 0.25, y: 0)
        )
    }

    func lightAlertTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpLightAlert"),
            arrow: .top
        )
    }

    func tireAlertTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpTireAlert"),
            arrow: UnitPoint(x: 0.75, y: 0)
        )
    }

    func brakeAlertTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpBrakeAlert"),
            arrow: UnitPoint(x: 0.9, y: 0)
        )
    }
}
