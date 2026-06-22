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

import FlowStacks
import SwiftUI

class DashboardCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case settings
        case statistics
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = DashboardServiceLocator.instance.provideDashboardView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: AppCoordinatorViewModel?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .settings: CoordinatorServiceLocator.instance.provideSettingsCoordinator(parentCoordinator: self)
        case .statistics: StatisticsServiceLocator.instance.provideStatisticsView(coordinator: self)
        }
    }

    @MainActor
    func showSettingsScreen() {
        show(.settings)
    }

    @MainActor
    func showStatisticsScreen() {
        show(.statistics)
    }

    @MainActor
    func showBleScanScreen() {
        (parentCoordinator as? AppCoordinatorViewModel)?.showBleScanScreen()
    }
}

struct DashboardCoordinator: View {
    @ObservedObject var viewModel: DashboardCoordinatorViewModel

    init(viewModel: DashboardCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: DashboardCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
