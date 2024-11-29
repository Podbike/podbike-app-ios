import FirebaseCore
import SwiftUI

@main
struct PodbikeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let appCoordinator = CoordinatorServiceLocator.instance.provideAppCoordinator()

    var body: some Scene {
        WindowGroup {
            appCoordinator
                .preferredColorScheme(.dark)
                .environment(\.sizeCategory, .medium)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        return true
    }
}
