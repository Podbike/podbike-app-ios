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
