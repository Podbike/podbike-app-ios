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

class FrikarInfoViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let bleManager: BleManager

    private var dataFetchTask: Task<Void, Never>?

    @Published private(set) var frikarConfig: FrikarConfig?
    @Published private(set) var isFetchError: Bool = false

    init(
        coordinator: BaseCoordinator?,
        bleManager: BleManager
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager

        super.init()

        fetchData()
    }

    deinit {
        dataFetchTask?.cancel()
    }

    private func fetchData() {
        dataFetchTask?.cancel()
        isFetchError = false

        dataFetchTask = Task { @MainActor [weak self] in
            let result = await self?.bleManager.getFrikarConfig()
            _ = { [weak self] in
                self?.frikarConfig = result
                if result == nil { self?.isFetchError = true }
            }()
        }
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
