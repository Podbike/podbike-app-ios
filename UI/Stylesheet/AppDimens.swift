import SwiftUI

enum AppDimens {
    static let padding4 = 4.0
    static let padding8 = 8.0
    static let padding16 = 16.0
    static let padding24 = 24.0
    static let padding32 = 32.0
    static let padding48 = 48.0
    static let padding64 = 64.0
}

enum AppSpacers {
    static let w4: some View = Spacer().frame(width: 4)
    static let w8: some View = Spacer().frame(width: 8)
    static let w12: some View = Spacer().frame(width: 12)
    static let w16: some View = Spacer().frame(width: 16)
    static let w48: some View = Spacer().frame(width: 48)
    static let w64: some View = Spacer().frame(width: 64)

    static let h4: some View = Spacer().frame(height: 4)
    static let h8: some View = Spacer().frame(height: 8)
    static let h12: some View = Spacer().frame(height: 12)
    static let h16: some View = Spacer().frame(height: 16)
    static let h32: some View = Spacer().frame(height: 32)
    static let h48: some View = Spacer().frame(height: 48)
    static let h64: some View = Spacer().frame(height: 64)

    static func w(_ width: CGFloat) -> some View { Spacer().frame(width: width) }
    static func h(_ height: CGFloat) -> some View { Spacer().frame(height: height) }
}
