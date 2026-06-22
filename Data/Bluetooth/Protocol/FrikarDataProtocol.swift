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

import Combine

protocol FrikarDataProtocol {
    var temperature: CurrentValueSubject<Int?, Never> { get } // Celsius
    var speed: CurrentValueSubject<Int?, Never> { get } // km/h
    var averageSpeed: CurrentValueSubject<Int?, Never> { get } // km/h
    var batteryPercent: CurrentValueSubject<Int?, Never> { get } // %
    var range: CurrentValueSubject<Int?, Never> { get } // km
    var totalDistance: CurrentValueSubject<Int?, Never> { get } // meters
    var lightsStatus: CurrentValueSubject<LightsStatus?, Never> { get } // flags
    var assistanceLevel: CurrentValueSubject<Int?, Never> { get } // 0-5
    var cadenceLevel: CurrentValueSubject<Int?, Never> { get } // 1-9
    var generatedPower: CurrentValueSubject<Int?, Never> { get } // Watt
}
