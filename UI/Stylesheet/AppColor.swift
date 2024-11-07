import SwiftUI

enum AppColor {
    static let accent = Color(hex: 0x44d62c)
    static let background = Color.black
    static let text = Color(hex: 0xf0f0f0)
    static let headlineText = Color.white

    static let backgroundGradient =
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: 0x353a40), Color(hex: 0x16171b)]),
            startPoint: .top,
            endPoint: .bottom
        )
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
