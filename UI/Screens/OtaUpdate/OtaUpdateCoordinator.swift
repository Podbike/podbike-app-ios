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

class OtaUpdateCoordinatorViewModel: ObservableObject, BaseCoordinatorViewModelProtocol {
    enum Screen: BaseScreen {
        case otaLicense
        case otaTransfer
        case otaUpgrade
    }

    let parentCoordinator: BaseCoordinator?
    private lazy var serviceLocator = OtaUpdateServiceLocator(coordinator: self)

    lazy var rootView: some View = serviceLocator.provideOtaUpdateCheckView()

    @Published var routes: Routes<Screen> = []

    init(parentCoordinator: BaseCoordinator?) {
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func provideView(forScreen screen: Screen) -> some View {
        switch screen {
        case .otaLicense: serviceLocator.provideOtaUpdateLicenseView()
        case .otaTransfer: serviceLocator.provideOtaUpdateTransferView()
        case .otaUpgrade: serviceLocator.provideOtaUpgradeView()
        }
    }

    @MainActor
    func showLicenseScreen() {
        show(.otaLicense)
    }

    @MainActor
    func showOtaTransferScreen() {
        show(.otaTransfer)
    }

    @MainActor
    func showOtaUpgradeScreen() {
        show(.otaUpgrade)
    }

    @MainActor
    func dismissUpdate() {
        parentCoordinator?.goBackToCoordinatorRoot()
    }
}

struct OtaUpdateCoordinator: View {
    @ObservedObject var viewModel: OtaUpdateCoordinatorViewModel

    init(viewModel: OtaUpdateCoordinatorViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            viewModel.rootView
                .flowDestination(for: OtaUpdateCoordinatorViewModel.Screen.self) { screen in
                    viewModel.provideView(forScreen: screen)
                }
        }
    }
}
