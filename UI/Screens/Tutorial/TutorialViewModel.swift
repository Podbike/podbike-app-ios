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

class TutorialViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let userPreferences: UserPreferences

    @Published var selectedPage: Int

    init(coordinator: BaseCoordinator?, userPreferences: UserPreferences, startFromPage: Int? = nil) {
        self.coordinator = coordinator
        self.userPreferences = userPreferences
        self.selectedPage = startFromPage ?? 1
    }

    @MainActor
    func closeTutorial() {
        userPreferences.isTutorialShown = true
        coordinator?.dismiss()
    }
}
