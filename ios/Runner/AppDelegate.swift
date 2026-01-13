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

        // 1. Initialize Google Maps Key FIRST
        // We do this before plugins register to ensure the service is ready.
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String {
            GMSServices.provideAPIKey(apiKey)
            print("API Key check: \(Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? "Not Found")")
        } else {
            print("❌ Google Maps API Key missing or invalid in Info.plist")
        }

        // 2. Register Plugins (Flutter)
        GeneratedPluginRegistrant.register(with: self)

        // 3. Setup Notifications
        application.registerForRemoteNotifications()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications")
        // Explicitly setting the APNS token is great for Firebase stability
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
}