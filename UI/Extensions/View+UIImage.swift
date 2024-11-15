import SwiftUI
import UIKit

extension View {
    @MainActor
    func toUIImage(scale: CGFloat? = nil) -> UIImage {
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: self)

            renderer.scale = scale ?? UIScreen.main.scale
            return renderer.uiImage!
        } else {
            let controller = UIHostingController(rootView: self)
            let view = controller.view!

            let targetSize = controller.view.intrinsicContentSize
            let bounds = CGRect(origin: .zero, size: targetSize)
            view.bounds = bounds.offsetBy(dx: 0, dy: bounds.height)
            view.backgroundColor = .clear

            let renderer = UIGraphicsImageRenderer(size: targetSize)

            return renderer.image { _ in
                view
                    .drawHierarchy(
                        in: bounds,
                        afterScreenUpdates: true
                    )
            }
        }
    }

    @MainActor
    func toImage(scale: CGFloat? = nil) -> Image {
        Image(uiImage: self.toUIImage())
    }
}
