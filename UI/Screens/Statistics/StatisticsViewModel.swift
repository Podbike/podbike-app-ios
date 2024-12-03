import Combine
import Foundation
import SwiftUI

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

    @Published var averageSpeedValue: String = "-"
    @Published var averageSpeedUnit: String = ""

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

        bleManager.temperature.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTemperatureUpdate(temperatureCelsius: $0) }
            .store(in: &dataCancellables)

        bleManager.totalDistance.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onTotalDistanceUpdate(totalDistanceInMeters: $0) }
            .store(in: &dataCancellables)

        bleManager.averageSpeed.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onAverageSpeedUpdate(averageSpeedInKmph: $0) }
            .store(in: &dataCancellables)

        bleManager.generatedPower.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onGeneratedPowerUpdate(powerInWatts: $0) }
            .store(in: &dataCancellables)

        bleManager.batteryPercent.dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.onBatteryPercentUpdate($0) }
            .store(in: &dataCancellables)

        bleManager.averageRpm.dropFirst()
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
            totalDistanceValue = String(lround(convertedTotalDistance))
            co2Value = String(lround(totalDistanceInKm * (0.1204 - 0.00044)))
        } else {
            totalDistanceValue = "-"
            co2Value = "-"
        }

        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        totalDistanceUnit = formatter.string(from: selectedDistanceUnit.unitType)
    }

    private func onAverageSpeedUpdate(averageSpeedInKmph: Int?) {
        let selectedSpeedUnit = userPreferences.speedUnit

        if let averageSpeedInKmph {
            let convertedAverageSpeed = selectedSpeedUnit.converted(kilometersPerHour: Double(averageSpeedInKmph))
            averageSpeedValue = String(lround(convertedAverageSpeed))
        } else {
            averageSpeedValue = "-"
        }

        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .short
        averageSpeedUnit = formatter.string(from: selectedSpeedUnit.unitType).replacingOccurrences(of: "hr", with: "h")
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
        guard let tripStartTime = tripMetrics.tripStartTime else { return }
        let tripTimeInSeconds = tripStartTime.distance(to: Date.now)
        let tripTimeInMinutes = Int(tripTimeInSeconds / 60)
        tripTimeValue = String(tripTimeInMinutes)
    }

    @MainActor
    func dismiss() {
        coordinator?.dismiss()
    }
}
