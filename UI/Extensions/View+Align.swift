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
