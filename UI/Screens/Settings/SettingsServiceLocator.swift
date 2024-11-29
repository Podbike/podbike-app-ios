import SwiftUI

class SettingsServiceLocator {
    static let instance = SettingsServiceLocator()

    func provideSettingsView(coordinator: SettingsCoordinatorViewModel) -> some View {
        let model = SettingsViewModel(
            coordinator: coordinator,
            userPreferences: UserPreferences.instance
        )
        return SettingsView(viewModel: model)
    }
}
