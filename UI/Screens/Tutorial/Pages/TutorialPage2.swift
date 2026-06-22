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

struct TutorialPage2: View {
    var body: some View {
        VStack {

            Text("TutorialSymbols").headline
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
            Spacer()

            Text("TutorialAssistance").label

            AppSpacers.h12

            Image(.Tutorial.electricAssistance)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, AppDimens.padding16)

            Spacer()
            Spacer()

            Text("TutorialCadence").label

            AppSpacers.h12

            Image(.Tutorial.cadence)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, AppDimens.padding8)

            Spacer()
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    TutorialServiceLocator.instance.provideTutorialView(
        coordinator: nil,
        startFromPage: 2
    )
}
