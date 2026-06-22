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

let materialIconsFontName = "Material Design Icons"

enum AppIcon {
    static let statistics = "\u{F0129}".materialIcon
    static let settings = "\u{F0493}".materialIcon
    static let settingsRefresh = "\u{F145E}".materialIcon
    static let settingsTransfer = "\u{F105B}".materialIcon
    static let help = "\u{F02D7}".materialIcon
    static let power = "\u{F0425}".materialIcon
    static let demister = "\u{F0D61}".materialIcon
    static let lock = "\u{F033E}".materialIcon
    static let unlock = "\u{F033F}".materialIcon
    static let phoneKey = "\u{F094E}".materialIcon
    static let compass = "\u{F018B}".materialIcon
    static let charging = "\u{F0084}".materialIcon
    static let update = "\u{F06B0}".materialIcon
    static let tutorial = "\u{F101F}".materialIcon
    static let service = "\u{F05B7}".materialIcon
    static let store = "\u{F07C7}".materialIcon
    static let issue = "\u{F0028}".materialIcon
    static let chevronRight = "\u{F0142}".materialIcon
    static let arrowLeft = "\u{F004D}".materialIcon
    static let logOut = "\u{F0343}".materialIcon
    static let accountEdit = "\u{F06BC}".materialIcon
    static let carLights = "\u{F0C4A}".materialIcon
    static let fogLights = "\u{F0C4B}".materialIcon
    static let highBeam = "\u{F0C4C}".materialIcon
    static let phone = "\u{F03F2}".materialIcon
    static let assist = "\u{F15B4}".materialIcon
    static let music = "\u{F075A}".materialIcon
    static let bluetoothOff = "\u{F00B2}".materialIcon
    static let snowAlert = "\u{F0F29}".materialIcon
    static let tractionControl = "\u{F0D64}".materialIcon
    static let lightAlert = "\u{F190D}".materialIcon
    static let tireAlert = "\u{F0C4D}".materialIcon
    static let brakeAlert = "\u{F0D5F}".materialIcon
    static let privacyPolicy = "\u{F088F}".materialIcon
    static let termsAndConditions = "\u{F0216}".materialIcon
    static let check = "\u{F012C}".materialIcon
}

extension String {
    var materialIcon: MaterialIcon { MaterialIcon(self) }
}

struct MaterialIcon: View {
    let glyph: String
    let font: Font

    init(_ glyph: String, size: CGFloat = 32) {
        self.glyph = glyph
        self.font = .custom(materialIconsFontName, size: size)
    }

    var body: some View {
        Text(verbatim: self.glyph)
            .font(self.font)
    }
}

extension MaterialIcon {
    func size(_ size: CGFloat) -> MaterialIcon {
        MaterialIcon(self.glyph, size: size)
    }
}
