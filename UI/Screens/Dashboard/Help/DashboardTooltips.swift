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

// MARK: Help Tooltips

extension View {
    func speedometerTooltip(_ tooltipView: Binding<AnyView?>, speedUnit: String) -> some View {
        self.overlay {
            self
                .padding(.vertical, -20)
                .tooltip(
                    tooltipView: tooltipView,
                    text: String(format: String(localized: "HelpSpeedometer"), speedUnit),
                    arrow: .top
                )
        }
    }

    func batteryAndRangeTooltip(_ tooltipView: Binding<AnyView?>, distanceUnit: String) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(format: String(localized: "HelpBatteryAndRange"), distanceUnit),
            arrow: .top
        )
    }

    func odometerTooltip(_ tooltipView: Binding<AnyView?>, distanceUnit: String) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(format: String(localized: "HelpOdometer"), distanceUnit),
            arrow: UnitPoint(x: 0.2, y: 1.0)
        )
    }

    func modeAndLightsTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpModeAndLights"),
            arrow: UnitPoint(x: 0.9, y: 1.0)
        )
    }

    func assistanceTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpAssistance"),
            arrow: .bottom
        )
    }

    func cadenceTooltip(_ tooltipView: Binding<AnyView?>) -> some View {
        self.tooltip(
            tooltipView: tooltipView,
            text: String(localized: "HelpCadence"),
            arrow: .bottom
        )
    }
}
