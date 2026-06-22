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

struct Mock {
    static var frikarConfigMock = """
        {
            "Product name":   "Frikar",
            "ReleaseID":  "R1.0.0",
            "ProductID":  "A294-1",
            "Frame number":   "000013-F8-1-00-036",
            "ECU Modules":    [{
                    "Board name": "Haarek",
                    "BoardID":    "E126-5",
                    "Serial number":  "5392596",
                    "Board position": "Main Controller",
                    "FWVersion":  "R01-57"
                }, {
                    "Board name": "BLE",
                    "BoardID":    "E126-5",
                    "Serial number":  "5392596",
                    "Board position": "Main BLE",
                    "FWVersion":  "R01-52"
                }, {
                    "Board name": "FENRIS",
                    "BoardID":    "E133-2",
                    "Serial number":  "5158581",
                    "Board position": "Pedal Generator",
                    "FWVersion":  "R01-55"
                }, {
                    "Board name": "FENRIS",
                    "BoardID":    "E133-2",
                    "Serial number":  "5158544",
                    "Board position": "Motor Left",
                    "FWVersion":  "R01-55"
                }, {
                    "Board name": "FENRIS",
                    "BoardID":    "E133-2",
                    "Serial number":  "5158540",
                    "Board position": "Motor Right",
                    "FWVersion":  "R01-55"
                }, {
                    "Board name": "Baldr",
                    "BoardID":    "E131-1",
                    "Serial number":  "5110814",
                    "Board position": "Front Left",
                    "FWVersion":  "R01-04"
                }, {
                    "Board name": "Baldr",
                    "BoardID":    "E131-1",
                    "Serial number":  "5110824",
                    "Board position": "Front Right",
                    "FWVersion":  "R01-04"
                }, {
                    "Board name": "Baldr",
                    "BoardID":    "E131-1",
                    "Serial number":  "5110932",
                    "Board position": "Rear Left",
                    "FWVersion":  "R01-04"
                }, {
                    "Board name": "Baldr",
                    "BoardID":    "E131-1",
                    "Serial number":  "5110950",
                    "Board position": "Rear Right",
                    "FWVersion":  "R01-04"
                }]
        }
    """
}
