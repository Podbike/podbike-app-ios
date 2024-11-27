import Combine
import Foundation

protocol FrikarDataProtocol {
    var speed: CurrentValueSubject<Double, Never> { get } // km/h
}
