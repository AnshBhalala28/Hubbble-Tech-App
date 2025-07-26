//import UIKit
//import Flutter
//import GoogleMaps
//import FirebaseCore
//
//@main
//@objc class AppDelegate: FlutterAppDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    // ✅ Provide your Google Maps API key
//    GMSServices.provideAPIKey("AIzaSyDJoqPDa2eaOuIDT_QRKKI7IZxFU-UOoDE")
//
//    // ✅ Initialize Firebase
//    FirebaseApp.configure()
//
//    GeneratedPluginRegistrant.register(with: self)
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//}

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
         GMSServices.provideAPIKey("AIzaSyDkTKndT7jGcmnVYK1xgPL3drb7oqAQAAY")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for Apple Remote Notifications")
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
}
