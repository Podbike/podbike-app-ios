import SwiftUI

class SettingsServiceLocator {
    static let instance = SettingsServiceLocator()

    func provideSettingsView(coordinator: RootCoordinatorViewModel) -> some View {
        let model = SettingsViewModel(coordinator: coordinator)
        return SettingsView(viewModel: model)
    }
}
