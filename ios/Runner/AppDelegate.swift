import Flutter
import UIKit
import FirebaseCore
import UserNotifications
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)

    // Set UNUserNotificationCenter delegate so we can handle foreground notifications
    UNUserNotificationCenter.current().delegate = self

    // Request notification permissions (alerts, badge, sound)
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
      if let error = error {
        NSLog("UNUserNotificationCenter requestAuthorization error: \(error.localizedDescription)")
      } else {
        NSLog("Notification permission granted: \(granted)")
      }
    }

    // Register with APNs (this triggers didRegisterForRemoteNotificationsWithDeviceToken)
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Forward the APNs device token to Firebase Messaging
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    // Optional: print APNs token (hex) for debugging
    let tokenParts = deviceToken.map { data -> String in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    NSLog("APNs device token: \(token)")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    NSLog("Failed to register for remote notifications: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }

  // MARK: - UNUserNotificationCenterDelegate methods (override because FlutterAppDelegate already declares them)

  // Called when a notification is delivered while the manager is in the foreground.
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }

  // Called when the user taps the notification (manager opened from background/terminated)
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
  }
}
