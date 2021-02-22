

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  //Manages the behaviors of the app, doesn't set any special launch options.
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    return true
  }

  //Starts the lifecycle of the app.
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
