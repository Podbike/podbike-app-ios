import SwiftUI

enum AppColor {
    static let accent = Color(hex: 0x44d62c)
    static let dimAccent = Color(hex: 0x3bac28)
    static let white = Color.white
    static let text = Color(hex: 0xf0f0f0)
    static let dimGray = Color(hex: 0x696969)
    static let indicatorBackground = Color(hex: 0xc4c4c4)
    static let quaternary = Color(hex: 0x16171b)
    static let alert = Color(hex: 0xd62918)

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
