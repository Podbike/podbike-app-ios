import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep(millis: Int) async {
        try? await Task.sleep(nanoseconds: UInt64(millis) * NSEC_PER_MSEC)
    }
}
