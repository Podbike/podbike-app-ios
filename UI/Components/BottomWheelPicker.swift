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

struct BottomWheelPicker<Entry: Hashable & CustomStringConvertible>: View {
    @Binding private var isPresented: Bool
    private let label: LocalizedStringKey
    private let entries: [Entry]
    @Binding private var selection: Entry
    private let onDismiss: (() -> Void)?

    init(
        isPresented: Binding<Bool>,
        label: LocalizedStringKey,
        entries: [Entry],
        selection: Binding<Entry>,
        onDismiss: (@MainActor () -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.label = label
        self.entries = entries
        self._selection = selection
        self.onDismiss = onDismiss
    }

    @ViewBuilder
    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
            }

            if isPresented {
                ZStack(alignment: .top) {
                    Picker(selection: $selection, label: Text(label)) {
                        ForEach(entries, id: \.self) { entry in
                            Text(
                                LocalizedStringKey(entry.description)
                            )
                            .tag(entry)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .padding(-AppDimens.padding16)
                    .background(.regularMaterial)

                    HStack {
                        Text(label)
                            .font(AppFont.label)
                            .padding(.vertical, AppDimens.padding8)
                            .padding(.horizontal, AppDimens.padding16)

                        Spacer()

                        Button(action: dismiss,
                               label: {
                                   Text("Done")
                                       .tint(Color.blue)
                                       .font(AppFont.title)
                                       .padding(.vertical, AppDimens.padding8)
                                       .padding(.horizontal, AppDimens.padding16)
                               })
                    }
                    .background(Color(UIColor.lightGray).brightness(0.1))
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
                .colorScheme(.light)
            }
        }
    }

    private func dismiss() {
        withAnimation(
            .easeIn(duration: 0.2),
            { isPresented = false }
        )
        onDismiss?()
    }
}
