import Foundation
import Combine

typealias YModemStream = AnyPublisher<Data, Never>

protocol YModemTransportProtocol {
    var dataStream: YModemStream { get }
    var controlStream: YModemStream { get }

    func sendYModemData(_ data: Data, withResponse: Bool)
    func sendYModemControl(_ data: Data)
}
