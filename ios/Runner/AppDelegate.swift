//
// import Flutter
// import UIKit
// import FirebaseMessaging
// import GoogleMaps
// @main
// @objc class AppDelegate: FlutterAppDelegate {
//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//         GeneratedPluginRegistrant.register(with: self)
//         application.registerForRemoteNotifications()
//          GMSServices.provideAPIKey("AIzaSyDkTKndT7jGcmnVYK1xgPL3drb7oqAQAAY")
//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }
//     override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//         print("Registered for Apple Remote Notifications")
//         Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
//     }
// }
import Flutter
import UIKit
import FirebaseMessaging
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        application.registerForRemoteNotifications()

        // ✅ Read Google Maps API Key from Info.plist
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
            GMSServices.provideAPIKey(apiKey)
        } else {
            print("❌ Google Maps API Key missing in Info.plist")
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
}
