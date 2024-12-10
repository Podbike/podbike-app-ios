import SwiftUI

extension View {
    func alignLeft() -> some View {
        modifier(AlignLeftModifier())
    }

    func alignRight() -> some View {
        modifier(AlignRightModifier())
    }

    func alignTop() -> some View {
        modifier(AlignTopModifier())
    }

    func alignBottom() -> some View {
        modifier(AlignBottomModifier())
    }
}

private struct AlignLeftModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            content
            Spacer()
        }
    }
}

private struct AlignRightModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            content
        }
    }
}

private struct AlignTopModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
            Spacer()
        }
    }
}

private struct AlignBottomModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Spacer()
            content
        }
    }
}
