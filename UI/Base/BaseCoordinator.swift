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

    var canGoBack: Bool {
        routes.canGoBack()
    }
}
