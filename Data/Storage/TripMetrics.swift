import Foundation

class TripMetrics {
    static let instance = TripMetrics()
    private init() {}

    var tripStartTime: Date? = nil
}
