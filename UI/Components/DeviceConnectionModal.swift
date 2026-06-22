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

public struct DeviceConnectionModal: View {
    private let isPresented: Bool
    private let deviceName: String
    private let cancelAction: () -> Void

    public init(isPresented: Bool, deviceName: String, cancelAction: @escaping () -> Void) {
        self.isPresented = isPresented
        self.deviceName = deviceName
        self.cancelAction = cancelAction
    }

    public var body: some View {
        ZStack {
            if isPresented {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()

                    HStack {
                        Spacer()

                        VStack(spacing: 0) {
                            AppSpacers.h16

                            ProgressView()
                                .controlSize(.large)
                                .padding(AppDimens.padding8)

                            let message = String(localized: "ConnectingTo") + "\n" + deviceName
                            Text(message)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColor.text)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppDimens.padding32)

                            AppSpacers.h16

                            Divider()

                            Button(
                                action: cancelAction,
                                label: {
                                    Text("Cancel")
                                        .font(.system(size: 18))
                                        .foregroundColor(AppColor.text)
                                        .padding(AppDimens.padding16)
                                        .frame(maxWidth: .infinity)
                                }
                            )
                            .foregroundColor(.black)
                        }
                        .fixedSize()
                        .background(.thinMaterial)
                        .cornerRadius(20)

                        Spacer()
                    }
                }
                .colorScheme(.dark)
            }
        }
        .animation(.default, value: isPresented)
    }
}

#Preview {
    ZStack {
        AppColor.backgroundGradient
            .ignoresSafeArea()

        DeviceConnectionModal(
            isPresented: true,
            deviceName: "TEST DEVICE",
            cancelAction: {}
        )
    }
}
