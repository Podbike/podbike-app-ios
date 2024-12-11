import Foundation
import Combine

typealias OtaTransferProgress = CurrentValueSubject<Double, Never>

protocol OtaFileTransferProtocol {
    func transferFile(_ otaFile: OtaFile) throws -> OtaTransferProgress
    func runUpgrade()
}
