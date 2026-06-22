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

class SettingsCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case deviceSelection
        case firmwareUpdate
        case frikarInfo
        case policies
    }

    let parentCoordinator: BaseCoordinator?

    lazy var rootView: some View = SettingsServiceLocator.instance.provideSettingsView(coordinator: self)

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .deviceSelection: CoordinatorServiceLocator.instance.provideDeviceSelectionCoordinator(parentCoordinator: self)
        case .firmwareUpdate: CoordinatorServiceLocator.instance.provideOtaUpdateCoordinator(parentCoordinator: self)
        case .frikarInfo: FrikarInfoServiceLocator.instance.provideFrikarInfoView(coordinator: self)
        case .policies: PoliciesServiceLocator.instance.providePoliciesView(coordinator: self)
        }
    }

    @MainActor
    func showDeviceSelection() {
        show(.deviceSelection)
    }

    @MainActor
    func showFirmwareUpdate() {
        show(.firmwareUpdate)
    }

    @MainActor
    func showPolicies() {
        show(.policies)
    }

    @MainActor
    func showFrikarInfo() {
        show(.frikarInfo)
    }
}

struct SettingsCoordinator: View {
    @ObservedObject var viewModel: SettingsCoordinatorViewModel

    init(viewModel: SettingsCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        if viewModel.routes.count == 0 {
            viewModel.rootView
        } else {
            FlowStack($viewModel.routes, withNavigation: true) {
                viewModel.rootView
                    .flowDestination(for: SettingsCoordinatorViewModel.Screen.self) { screen in
                        viewModel.provideView(forScreen: screen)
                    }
            }
        }
    }
}
