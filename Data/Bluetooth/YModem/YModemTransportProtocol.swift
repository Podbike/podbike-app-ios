import Foundation
import Combine

protocol YModemTransportProtocol {
    var dataStream: AnyPublisher<Data, Never> { get }
    var controlStream: AnyPublisher<Data, Never> { get }

    func sendYModemData(_ data: Data)
    func sendYModemControl(_ data: Data)
}
