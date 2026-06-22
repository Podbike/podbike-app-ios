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
    func tooltip(tooltipView: Binding<AnyView?>, text: String, arrow: UnitPoint, isPresented: Bool = false) -> some View {
        self
            .overlay {
                GeometryReader { geometry in
                    let parentFrame = geometry.frame(in: .global)

                    let tooltip =
                        Tooltip(
                            text: text,
                            parentFrame: parentFrame,
                            arrow: arrow
                        )
                        .id(text)

                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tooltipView.wrappedValue = AnyView(tooltip)
                        }
                        .onAppear {
                            if isPresented {
                                tooltipView.wrappedValue = AnyView(tooltip)
                            }
                        }
                }
            }
    }
}

private struct Tooltip: View {
    let text: String
    let parentFrame: CGRect
    let arrow: UnitPoint

    @State private var tooltipSize: CGSize = .zero
    @State private var isRendered: Bool = true

    private var contentSizeReader: some View {
        GeometryReader { geometry in
            let contentSize = geometry.size
            Color.clear
                .onAppear {
                    self.tooltipSize = contentSize
                    // kick in animation
                    self.isRendered = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.isRendered = true
                    }
                }
                .onChange(of: contentSize) {
                    self.tooltipSize = $0
                }
        }
    }

    public var body: some View {
        let horizontalPadding = AppDimens.padding16
        var xOffset = self.parentFrame.minX + (self.parentFrame.width - self.tooltipSize.width) / 2
        xOffset += (0.5 - arrow.x) * (self.tooltipSize.width - 50)
        xOffset = max(horizontalPadding, xOffset)
        xOffset = min(xOffset, UIScreen.width - self.tooltipSize.width - horizontalPadding)

        let isTopArrow = self.arrow.y == 0
        let yOffset = isTopArrow ?
            self.parentFrame.maxY :
            self.parentFrame.minY - self.tooltipSize.height

        let arrowXOffset = parentFrame.midX - xOffset

        return ZStack {
            if self.isRendered {
                TooltipBody(text: self.text, isTopArrow: isTopArrow, arrowXOffset: arrowXOffset)
                    .transition(
                        .scale(scale: 0, anchor: self.arrow)
                        .combined(with: .opacity)
                    )
            }
        }
        .offset(x: xOffset, y: yOffset)
        .ignoresSafeArea()
        .background(self.contentSizeReader)
        .opacity(self.tooltipSize != .zero ? 1 : 0)
        .animation(.bouncy(duration: 0.2), value: self.isRendered)
    }
}

private struct TooltipBody: View {
    let text: String
    let isTopArrow: Bool
    let arrowXOffset: CGFloat

    public var body: some View {
        let arrowWidth = 20.0
        let arrowHeight = 10.0
        let arrowXOffset = arrowXOffset - arrowWidth / 2
        
        VStack(alignment: .leading, spacing: 0) {
            if isTopArrow {
                Triangle()
                    .frame(width: arrowWidth, height: arrowHeight)
                    .offset(x: arrowXOffset)
                    .foregroundStyle(.ultraThickMaterial)
                    .padding(.bottom, -1)
                    .zIndex(1)
            }

            ZStack {
                VStack(spacing: 0) {
                    let textComponents = self.text.split(maxSplits: 1, whereSeparator: \.isNewline)
                    let title = textComponents.first ?? ""
                    let description = textComponents.last ?? ""

                    Text(title)
                        .font(AppFont.strong)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)

                    Text(description)
                        .font(AppFont.label)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, AppDimens.padding16)
                .padding(.vertical, AppDimens.padding16)
                .frame(maxWidth: UIScreen.width - 100)
            }
            .id(self.text)
            .background(.ultraThickMaterial)
            .cornerRadius(8)
            .shadow(color: Color.black, radius: 5, y: isTopArrow ? 5 : -5)

            if !isTopArrow {
                Triangle()
                    .rotationEffect(.degrees(180))
                    .frame(width: arrowWidth, height: arrowHeight)
                    .offset(x: arrowXOffset)
                    .foregroundStyle(.ultraThickMaterial)
                    .padding(.top, -1)
            }
        }
        .colorScheme(.light)
        .padding(.vertical, AppDimens.padding4)
    }

    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            return path
        }
    }
}
