import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 1. Initialize Google Maps FIRST
        // Fetch the key and check if it's the placeholder string or empty
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""

        if !apiKey.isEmpty && apiKey != "$(GOOGLE_MAPS_API_KEY)" {
            GMSServices.provideAPIKey(apiKey)
        } else {
            print("⚠️ Warning: Google Maps API Key is missing or unconfigured in Info.plist")
        }

        // 2. Firebase Configuration
        // Only call this if you aren't handling initialization purely in Dart
        FirebaseApp.configure()

        // 3. Register Flutter Plugins
        GeneratedPluginRegistrant.register(with: self)

        // 4. Setup Notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        application.registerForRemoteNotifications()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 5. Explicitly map APNs token to Firebase Messaging
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        print("Successfully registered for notifications with device token.")
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}