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
    static let w24: some View = Spacer().frame(width: 24)
    static let w32: some View = Spacer().frame(width: 32)
    static let w48: some View = Spacer().frame(width: 48)
    static let w64: some View = Spacer().frame(width: 64)

    static let h4: some View = Spacer().frame(height: 4)
    static let h8: some View = Spacer().frame(height: 8)
    static let h12: some View = Spacer().frame(height: 12)
    static let h16: some View = Spacer().frame(height: 16)
    static let h24: some View = Spacer().frame(height: 24)
    static let h32: some View = Spacer().frame(height: 32)
    static let h48: some View = Spacer().frame(height: 48)
    static let h64: some View = Spacer().frame(height: 64)

    static func w(_ width: CGFloat) -> some View { Spacer().frame(width: width) }
    static func h(_ height: CGFloat) -> some View { Spacer().frame(height: height) }
}
