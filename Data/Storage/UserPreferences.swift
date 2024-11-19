import SwiftUI

class UserPreferences: ObservableObject {
    @AppStorage("idTutorialShown")
    var isTutorialShown: Bool = false

    @AppStorage("speedUnit")
    var speedUnit: SpeedUnit = .systemDefault

    @AppStorage("distanceUnit")
    var distanceUnit: DistanceUnit = .systemDefault

    @AppStorage("temperatureUnit")
    var temperatureUnit: TemperatureUnit = .systemDefault
}
