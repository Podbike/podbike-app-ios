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

import Foundation

class SplashViewModel: BaseViewModel {
    private weak var coordinator: AppCoordinatorViewModel?

    enum Constants {
#if DEBUG
        static let splashDurationInSeconds = 0.0
#else
        static let splashDurationInSeconds = 2.0
#endif
    }

    init(coordinator: AppCoordinatorViewModel?) {
        self.coordinator = coordinator
    }

    func didAppear() {
        waitAndShowTheApp()
    }

    private func waitAndShowTheApp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.splashDurationInSeconds) { [weak self] in
            self?.coordinator?.showTheApp()
        }
    }
}
