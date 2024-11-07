import FlowStacks
import Foundation
import SwiftUI

public protocol BaseCoordinatorViewModelProtocol: AnyObject {
    var parentCoordinator: (any BaseCoordinatorViewModelProtocol)? { get }

    associatedtype RootView: View
    var rootView: RootView { get set }

    associatedtype Screen: BaseScreen
    var routes: Routes<Screen> { get set }

    associatedtype ProvidedView: View
    func provideView(forScreen screen: Screen) -> ProvidedView
}

public extension BaseCoordinatorViewModelProtocol {
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

    func dismiss() {
        guard let lastScreen = routes.last?.screen else {
            debugPrint("⚠️ Trying to dismiss a view, but routes are empty")
            return
        }

        if routes.count == 0 {
            // If lastScreen is the only remaining screen in this route,
            // we should dismiss it from the parentCoordinator who was responsible of presenting it
            parentCoordinator?.dismiss()
        } else {
            dismiss(lastScreen)
        }
    }

    private func dismiss(_ screen: any BaseScreen) {
        switch screen.showTransition.dismissTransition {
        case .pop:
            routes.pop()
        case .dismiss:
            routes.dismiss()
        }
    }
}
