import SwiftUI

class SettingsServiceLocator {
    static let instance = SettingsServiceLocator()

    func provideSettingsView(coordinator: SettingsCoordinatorViewModel) -> some View {
        let model = SettingsViewModel(
            coordinator: coordinator,
            userPreferences: UserPreferences()
        )
        return SettingsView(viewModel: model)
    }
}
