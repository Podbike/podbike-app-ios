import Combine
import Foundation

class StatisticsViewModel: BaseViewModel {
    private weak var coordinator: BaseCoordinator?
    private let bleManager: BleManager
    private let userPreferences: UserPreferences
    private let tripMetrics: TripMetrics

    private var dataCancellables = Set<AnyCancellable>()

    @Published var temperatureValue: String = "-"
    @Published var temperatureUnit: String = ""

    @Published var totalDistanceValue: String = "-"
    @Published var totalDistanceUnit: String = ""

    @Published var speedUnit: String = ""

    @Published var averageTripSpeedValue: String = "-"
    @Published var averageTotalSpeedValue: String = "-"

    @Published var maxTripSpeedValue: String = "-"

    @Published var generatedPowerValue: String = "-"
    @Published var co2Value: String = "-"
    @Published var tripTimeValue: String = "-"
    @Published var averageRpmValue: String = "-"
    @Published var batteryPercentValue: String = "-"

    init(
        coordinator: BaseCoordinator?,
        bleManager: BleManager,
        userPreferences: UserPreferences,
        tripMetrics: TripMetrics
    ) {
        self.coordinator = coordinator
        self.bleManager = bleManager
        self.userPreferences = userPreferences
        self.tripMetrics = tripMetrics

        super.init()

        onSpeedUpdate(currentSpeedInKmph: tripMetrics.maxTripSpeed)

        subscribeToPublishers()
    }

    private func subscribeToPublishers() {
        userPreferences.objectWillChange
            .sink { [weak self] _ in self?.subscribeForFrikarData() }
            .store(in: &cancellables)

        subscribeForFrikarData()
    }

    private func subscribeForFrikarData() {
        dataCancellables.removeAll()

        bleManager.temperature
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTemperatureUpdate(temperatureCelsius: $0) }
            .store(in: &dataCancellables)

        bleManager.totalDistance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTotalDistanceUpdate(totalDistanceInMeters: $0) }
            .store(in: &dataCancellables)

        bleManager.averageSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onAverageSpeedUpdate(averageSpeedInKmph: $0) }
            .store(in: &dataCancellables)

        bleManager.speed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onSpeedUpdate(currentSpeedInKmph: $0) }
            .store(in: &dataCancellables)

        bleManager.generatedPower
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onGeneratedPowerUpdate(powerInWatts: $0) }
            .store(in: &dataCancellables)

        bleManager.batteryPercent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onBatteryPercentUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.averageRpm
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onAverageRpmUpdate($0) }
            .store(in: &dataCancellables)

        updateTripTime()
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in self?.updateTripTime() }
            .store(in: &dataCancellables)
    }

    private func onTemperatureUpdate(temperatureCelsius: Int?) {
        let selectedTemperatureUnit = userPreferences.temperatureUnit

        if let temperatureCelsius {
            let convertedTemperature = selectedTemperatureUnit.converted(degreesCelsius: Double(temperatureCelsius))
            temperatureValue = String(lround(convertedTemperature))

        } else {
            temperatureValue = "-"
        }

        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        temperatureUnit = formatter.string(from: selectedTemperatureUnit.unitType)
    }

    private func onTotalDistanceUpdate(totalDistanceInMeters: Int?) {
        let selectedDistanceUnit = userPreferences.distanceUnit

        if let totalDistanceInMeters {
            let totalDistanceInKm = Double(totalDistanceInMeters) / 1000
            let convertedTotalDistance = selectedDistanceUnit.converted(kilometers: totalDistanceInKm)
            let totalDistanceDecimalPlaces = selectedDistanceUnit == .meters ? 0 : 1
            totalDistanceValue = String(format: "%.\(totalDistanceDecimalPlaces)f", convertedTotalDistance)
            co2Value = String(format: "%.2f", totalDistanceInKm * (0.1204 - 0.00044))
            updateAverageTripSpeed(currentOdometer: totalDistanceInMeters)
        } else {
            totalDistanceValue = "-"
            co2Value = "-"
        }

        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        totalDistanceUnit = formatter.string(from: selectedDistanceUnit.unitType)
    }

    private func updateSpeedUnit() {
        let selectedSpeedUnit = userPreferences.speedUnit
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        speedUnit = formatter.string(from: selectedSpeedUnit.unitType).replacingOccurrences(of: "hr", with: "h")
    }

    private func onAverageSpeedUpdate(averageSpeedInKmph: Int?) {
        let selectedSpeedUnit = userPreferences.speedUnit
        updateSpeedUnit()

        if let averageSpeedInKmph {
            let convertedAverageSpeed = selectedSpeedUnit.converted(kilometersPerHour: Double(averageSpeedInKmph))
            averageTotalSpeedValue = String(lround(convertedAverageSpeed))
        } else {
            averageTotalSpeedValue = "-"
        }
    }


    private func updateAverageTripSpeed(currentOdometer: Int) {
        let selectedSpeedUnit = userPreferences.speedUnit
        updateSpeedUnit()

        guard let tripStartOdometer = tripMetrics.tripStartOdometer,
              let tripTime = tripMetrics.tripStartOffset?.distance(to: Date.now)
        else {
            averageTripSpeedValue = "0"
            return
        }

        let tripDistanceInKm = Double(currentOdometer - tripStartOdometer) / 1000
        let tripTimeInHours = Double(tripTime) / 3600
        let averageTripSpeedInKmph = tripDistanceInKm / tripTimeInHours

        let convertedAverageSpeed = selectedSpeedUnit.converted(kilometersPerHour: averageTripSpeedInKmph)
        averageTripSpeedValue = String(lround(convertedAverageSpeed))
    }

    private func onSpeedUpdate(currentSpeedInKmph: Int?) {
        guard let currentSpeedInKmph = currentSpeedInKmph else { return }

        let selectedSpeedUnit = userPreferences.speedUnit
        updateSpeedUnit()

        tripMetrics.maxTripSpeed = max(currentSpeedInKmph, tripMetrics.maxTripSpeed)

        let convertedMaxSpeed = selectedSpeedUnit.converted(kilometersPerHour: Double(tripMetrics.maxTripSpeed))
        maxTripSpeedValue = String(lround(convertedMaxSpeed))
    }

    private func onGeneratedPowerUpdate(powerInWatts: Int?) {
        generatedPowerValue = powerInWatts != nil ? String(powerInWatts!) : "-"
    }

    private func onAverageRpmUpdate(_ revolutionsPerMinute: Int?) {
        averageRpmValue = revolutionsPerMinute != nil ? String(revolutionsPerMinute!) : "-"
    }

    private func onBatteryPercentUpdate(_ batteryPercent: Int?) {
        batteryPercentValue = batteryPercent != nil ? String(batteryPercent!) : "-"
    }

    private func updateTripTime() {
        guard let tripStartTime = tripMetrics.tripStartOffset else {
            tripTimeValue = "0"
            return
        }

        if tripMetrics.tripInactivityStartTime != nil && tripTimeValue != "-" {
            return
        }

        let tripTimeInSeconds = tripStartTime.distance(to: Date.now)
        let tripTimeInMinutes = Int(tripTimeInSeconds / 60)
        tripTimeValue = String(tripTimeInMinutes)
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
