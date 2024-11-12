import SwiftUI

extension View {
    func centerHorizontally() -> some View {
        modifier(CenterHorizontallyModifier())
    }

    func centerVertically() -> some View {
        modifier(CenterVerticallyModifier())
    }
}

private struct CenterHorizontallyModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            content
            Spacer()
        }
    }
}

private struct CenterVerticallyModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Spacer()
            content
            Spacer()
        }
    }
}
