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
