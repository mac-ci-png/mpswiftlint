import UIKit
import mParticle_Apple_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let options = MParticleOptions(
            key: "REPLACE WITH APP KEY",
            secret:"REPLACE WITH APP SECRET"
        )
        options.dataPlanId = "my-org-data-plan"
        options.dataPlanVersion = 1 as NSNumber
        options.logLevel = .verbose
        MParticle.sharedInstance().start(with: options)
        // To validate, change name to "test-nav"
        let event = MPEvent(name: "test-nv", type: .navigation)
        if let event = event {
            MParticle.sharedInstance().logEvent(event)
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

