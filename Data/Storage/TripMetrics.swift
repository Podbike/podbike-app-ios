import Foundation

class TripMetrics {
    static let instance = TripMetrics()
    private init() {}

    var tripStartOffset: Date? //trip start time offseted by eventual pauses in disconnected or idle state
    var tripStartOdometer: Int?
    var maxTripSpeed: Int = 0
    var tripInactivityStartTime: Date?

    func reset() {
        tripStartOffset = nil
        tripStartOdometer = nil
        maxTripSpeed = 0
        tripInactivityStartTime = nil
    }
}
