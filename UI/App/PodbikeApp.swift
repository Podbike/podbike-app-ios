import FirebaseCore
import SwiftUI

@main
struct PodbikeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let appCoordinator = CoordinatorServiceLocator.instance.provideStartupCoordinator()

    var body: some Scene {
        WindowGroup {
            appCoordinator
                .preferredColorScheme(.dark)
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
