import SwiftUI

public protocol BaseScreen : Hashable {
    var showTransition: ScreenTransition.Show { get }
}

extension BaseScreen {
    var showTransition: ScreenTransition.Show {
        return .push
    }
}

public enum ScreenTransition {
    public enum Show {
        case push, present, presentFullScreen

        var dismissTransition: ScreenTransition.Dismiss {
            switch self {
            case .push:
                return .pop
            case .present, .presentFullScreen:
                return .dismiss
            }
        }
    }

    public enum Dismiss {
        case pop, dismiss
    }
}
