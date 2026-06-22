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

struct LightsStatus {
    let lowBeam: Bool
    let highBeam: Bool
    let rearLight: Bool
    let brakeLight: Bool
    let indicatorLeft: Bool
    let indicatorRight: Bool
    let reverseLight: Bool
    let runningLight: Bool

    init(
        lowBeam: Bool = false,
        highBeam: Bool = false,
        rearLight: Bool = false,
        brakeLight: Bool = false,
        indicatorLeft: Bool = false,
        indicatorRight: Bool = false,
        reverseLight: Bool = false,
        runningLight: Bool = false
    ) {
        self.lowBeam = lowBeam
        self.highBeam = highBeam
        self.rearLight = rearLight
        self.brakeLight = brakeLight
        self.indicatorLeft = indicatorLeft
        self.indicatorRight = indicatorRight
        self.reverseLight = reverseLight
        self.runningLight = runningLight
    }
}
