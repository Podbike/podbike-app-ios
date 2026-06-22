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

import Foundation

class CoordinatorServiceLocator {
    static let instance = CoordinatorServiceLocator()

    func provideAppCoordinator() -> AppCoordinator {
        AppCoordinator(
            viewModel: AppCoordinatorViewModel(
                bleManager: BleManager.instance,
                userPreferences: UserPreferences.instance
            )
        )
    }

    func provideSettingsCoordinator(parentCoordinator: BaseCoordinator) -> SettingsCoordinator {
        SettingsCoordinator(viewModel: SettingsCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideDeviceSelectionCoordinator(parentCoordinator: BaseCoordinator) -> DeviceSelectionCoordinator {
        DeviceSelectionCoordinator(viewModel: DeviceSelectionCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideDashboardCoordinator(parentCoordinator: AppCoordinatorViewModel) -> DashboardCoordinator {
        DashboardCoordinator(viewModel: DashboardCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }

    func provideOtaUpdateCoordinator(parentCoordinator: BaseCoordinator) -> OtaUpdateCoordinator {
        OtaUpdateCoordinator(viewModel: OtaUpdateCoordinatorViewModel(parentCoordinator: parentCoordinator))
    }
}
