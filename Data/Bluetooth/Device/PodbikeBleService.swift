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

import CoreBluetooth

enum PodbikeBleService {
    static let serviceUUID = CBUUID(string: "00001500-a619-448c-b990-2d716cba1130")

    private static func podbikeCharacteristic(_ shortUuid: String) -> CBUUID {
        var uuid = serviceUUID.uuidString
        let startIndex = uuid.index(uuid.startIndex, offsetBy: 4)
        let endIndex = uuid.index(startIndex, offsetBy: 4)
        uuid.replaceSubrange(startIndex ..< endIndex, with: shortUuid)
        return CBUUID(string: uuid)
    }

    static let speedUUID = podbikeCharacteristic("1501")
    static let temperatureUUID = podbikeCharacteristic("1502")
    static let generatedPowerUUID = podbikeCharacteristic("1503")
    static let averageRpmUUID = podbikeCharacteristic("1504")
    static let assistanceLevelUUID = podbikeCharacteristic("1505")
    static let cadenceLevelUUID = podbikeCharacteristic("1506")
    static let batteryUUID = podbikeCharacteristic("1507")
    static let lightsStatusUUID = podbikeCharacteristic("1508")
    static let tripTimeUUID = podbikeCharacteristic("1509")
    static let ftpControlUUID = podbikeCharacteristic("1510")
    static let ftpDataUUID = podbikeCharacteristic("1511")
    static let averageSpeedUUID = podbikeCharacteristic("1512")
    static let accessoriesUUID = podbikeCharacteristic("1513")
    static let bicycleUUID = podbikeCharacteristic("1514")
    static let totalDistanceUUID = podbikeCharacteristic("1515")
    static let rangeUUID = podbikeCharacteristic("1516")
    static let diagnosticsUUID = podbikeCharacteristic("1517")

    static let uartRxUUID = podbikeCharacteristic("1520")
    static let uartTxUUID = podbikeCharacteristic("1521")

    static let connectionWatchdog = speedUUID
}
