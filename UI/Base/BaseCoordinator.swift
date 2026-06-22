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
import Foundation
import SwiftUI

public typealias BaseCoordinator = any BaseCoordinatorViewModelProtocol

public protocol BaseCoordinatorViewModelProtocol: AnyObject {
    var parentCoordinator: BaseCoordinator? { get }

    associatedtype RootView: View
    var rootView: RootView { get set }

    associatedtype Screen: BaseScreen
    var routes: Routes<Screen> { get set }

    associatedtype ProvidedView: View
    func provideView(forScreen screen: Screen) -> ProvidedView

    var canGoBack: Bool { get }
}

public extension BaseCoordinatorViewModelProtocol {
    @MainActor
    func show(_ screen: Screen) {
        switch screen.showTransition {
        case .push:
            routes.push(screen)
        case .present:
            routes.presentSheet(screen, withNavigation: false)
        case .presentFullScreen:
            routes.presentCover(screen, withNavigation: false)
        }
    }

    @MainActor
    func dismiss() {
        guard let lastScreen = routes.last?.screen else {
            parentCoordinator?.dismiss()
            return
        }
        dismiss(lastScreen)
    }

    private func dismiss(_ screen: any BaseScreen) {
        switch screen.showTransition.dismissTransition {
        case .pop:
            routes.pop()
        case .dismiss:
            routes.dismiss()
        }
    }

    @MainActor
    func goBackToRoot() {
        if let parentCoordinator {
            routes.goBackToRoot()
            parentCoordinator.goBackToRoot()
        } else {
            routes.goBackTo(index: 0)
        }
    }

    @MainActor
    func goBackToCoordinatorRoot() {
        routes.goBackToRoot()
    }

    var canGoBack: Bool {
        routes.canGoBack()
    }
}
