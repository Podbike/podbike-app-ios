import SwiftUI

extension View {
    @ViewBuilder
    func transparentListBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            background(Color.clear)
        }
    }
}
