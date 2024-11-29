import Combine

protocol FrikarDataProtocol {
    var temperature: CurrentValueSubject<Int?, Never> { get } // Celsius
    var speed: CurrentValueSubject<Int?, Never> { get } // km/h
    var batteryPercent: CurrentValueSubject<Int?, Never> { get } // %
    var range: CurrentValueSubject<Int?, Never> { get } // km
    var totalDistance: CurrentValueSubject<Int?, Never> { get } // meters
    var lightsStatus: CurrentValueSubject<LightsStatus?, Never> { get } // flags
    var assistanceLevel: CurrentValueSubject<Int?, Never> { get } // 0-5
    var cadenceLevel: CurrentValueSubject<Int?, Never> { get } // 1-9
}
