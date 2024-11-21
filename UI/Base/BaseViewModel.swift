import Combine
import Foundation

class BaseViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
}
