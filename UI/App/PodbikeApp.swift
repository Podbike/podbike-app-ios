/*
 * Copyright (C) 2026 Phal AS
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

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
