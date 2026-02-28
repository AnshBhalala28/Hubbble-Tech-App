import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate { // 1. Add Protocol

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // KEEP: Native initialization like Firebase and Google Maps here
        FirebaseApp.configure()

        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
        if !apiKey.isEmpty && apiKey != "$(GOOGLE_MAPS_API_KEY)" {
            GMSServices.provideAPIKey(apiKey)
        }

        application.registerForRemoteNotifications()

        // DO NOT call GeneratedPluginRegistrant here anymore
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 2. NEW: This is the mandatory spot for plugin registration in UIScene
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
}