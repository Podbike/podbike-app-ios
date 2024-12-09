import Foundation
import Combine

protocol YModelTransportProtocol {
    var dataStream: AnyPublisher<Data, Never> { get }
    var controlStream: AnyPublisher<Data, Never> { get }

    func sendYModemData(_ data: Data)
}
