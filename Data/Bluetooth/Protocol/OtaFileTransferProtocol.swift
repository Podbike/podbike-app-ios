import Foundation
import Combine

typealias OtaTransferProgress = CurrentValueSubject<Double, Error>

protocol OtaFileTransferProtocol {
    func transferFile(_ otaFile: OtaFile) -> OtaTransferProgress
    func abortTransfer()
    func runUpgrade()
}
