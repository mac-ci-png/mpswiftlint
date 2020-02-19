import UIKit
import mParticle_Apple_SDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        guard let home = AppDelegate.getEnvironmentVar("HOME") else {
            exit(1)
        }
        
        let file = "\(home)/mpswiftlint.json"
        
        guard let contents = FileManager().contents(atPath: file) else {
            exit(1)
        }
        
        guard let stringValue = String(bytes: contents, encoding: .utf8) else {
            exit(1)
        }
        
        guard let obj = AppDelegate.jsonParse(stringValue) as? [String: Any] else {
            exit(1)
        }
        
        guard let type = obj["type"] as? String else {
            exit(1)
        }
        
        if type == "custom" {
            guard let name = obj["name"] as? String else {
                exit(1)
            }
            guard let subtype = obj["subtype"] as? String else {
                exit(1)
            }
            var theType = MPEventType.navigation
            switch subtype {
            case ".navigation":
                theType = MPEventType.navigation
                break
            case ".location":
                theType = MPEventType.location
                break
            case ".search":
                theType = MPEventType.search
                break
            case ".transaction":
                theType = MPEventType.transaction
                break
            case ".userContent":
                theType = MPEventType.userContent
                break
            case ".userPreference":
                theType = MPEventType.userPreference
                break
            case ".social":
                theType = MPEventType.social
                break
            case ".other":
                theType = MPEventType.other
                break
            case ".media":
                theType = MPEventType.media
                break
            default:
                exit(1)
            }
            
            let event = MPEvent(name: name, type: theType)
            if let event = event {
                var dict = event.dictionaryRepresentation
                dict["dt"] = "e"
                if var attributes = dict["attrs"] as? [String: Any] {
                    attributes.removeValue(forKey: "EventLength")
                    dict["attrs"] = attributes
                }
                var data: Data? = nil
                do {
                    try data = JSONSerialization.data(withJSONObject: dict, options: .init())
                } catch {
                    print("Exception was thrown: \(error)")
                }
                if let data = data {
                    let stringValue = String(bytes: data, encoding: .utf8)
                    if let stringValue = stringValue {
                        print("\(stringValue)")
                    }
                }
            }
        }
        
        exit(0);
    }
        
    class func jsonParse(_ data: String) -> Any? {
        var result: Any? = nil
        let rawData = data.data(using: .utf8)
        if let rawData = rawData {
            do {
                try result = JSONSerialization.jsonObject(with: rawData, options: .init())
            } catch {
                print("Exception was thrown: \(error)")
            }
            return result
        }
        return nil
    }
    
    class func getEnvironmentVar(_ name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)
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

