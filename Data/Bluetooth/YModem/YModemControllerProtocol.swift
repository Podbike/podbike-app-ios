import Foundation
import Combine

protocol YModemControllerProtocol {
    func getFrikarConfig() async -> FrikarConfig?
    func runUpgrade()
}
