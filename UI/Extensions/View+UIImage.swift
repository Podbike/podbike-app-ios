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
