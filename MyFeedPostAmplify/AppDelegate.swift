//
//  AppDelegate.swift
//  MyFeedPostAmplify
//
//  Created by Abhisek Ghosh on 13/09/22.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
import SVProgressHUD
import UserNotifications
import AWSPinpoint

import UserNotifications
import AWSPinpoint


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pinpoint: AWSPinpoint?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Instantiate Pinpoint
        let pinpointConfiguration = AWSPinpointConfiguration
            .defaultPinpointConfiguration(launchOptions: launchOptions)
        // Set debug mode to use APNS sandbox, make sure to toggle for your production app
        pinpointConfiguration.debug = true
        pinpoint = AWSPinpoint(configuration: pinpointConfiguration)

        // Present the user with a request to authorize push notifications
        registerForPushNotifications()
        
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        
        setUpProgress()
        
        do { //Initialize Amplify in the application
            Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
            try Amplify.configure()
            
            print("Amplify configured with auth plugin")
        } catch {
            print("An error occurred setting up Amplify: \(error)")
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

extension AppDelegate{
    func setUpProgress(){
//        SVProgressHUD.setDefaultStyle(.custom)
//        SVProgressHUD.setDefaultMaskType(.custom)
//        SVProgressHUD.setMinimumSize(CGSize(width: 80, height: 80))
//        SVProgressHUD.setRingThickness(2)
//        SVProgressHUD.setRingNoTextRadius(30)
//        SVProgressHUD.setBackgroundColor(UIColor.darkGray)
//        SVProgressHUD.setForegroundColor(UIColor(hue: 0.53, saturation: 0.53, brightness: 1, alpha: 1))
//        SVProgressHUD.setDefaultMaskType(.black)
    }
}


//Notification implementation

extension AppDelegate {
    

//    func application(
//        _: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
//    ) -> Bool {
//        // Instantiate Pinpoint
//        let pinpointConfiguration = AWSPinpointConfiguration
//            .defaultPinpointConfiguration(launchOptions: launchOptions)
//        // Set debug mode to use APNS sandbox, make sure to toggle for your production app
//        pinpointConfiguration.debug = true
//        pinpoint = AWSPinpoint(configuration: pinpointConfiguration)
//
//        // Present the user with a request to authorize push notifications
//        registerForPushNotifications()
//
//        return true
//    }

    // MARK: Push Notification methods

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("Permission granted: \(granted)")
                guard granted else { return }

                // Only get the notification settings if user has granted permissions
                self?.getNotificationSettings()
            }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }

            DispatchQueue.main.async {
                // Register with Apple Push Notification service
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: Remote Notifications Lifecycle
    func application(_: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        // Register the device token with Pinpoint as the endpoint for this user
        pinpoint?.notificationManager
            .interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
    }

    func application(_: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                        -> Void) {
        // if the app is in the foreground, create an alert modal with the contents
        if application.applicationState == .active {
            let alert = UIAlertController(title: "Notification Received",
                                          message: userInfo.description,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            UIApplication.shared.keyWindow?.rootViewController?.present(
                alert, animated: true, completion: nil
            )
        }

        // Pass this remote notification event to pinpoint SDK to keep track of notifications produced by AWS Pinpoint campaigns.
        pinpoint?.notificationManager.interceptDidReceiveRemoteNotification(
            userInfo, fetchCompletionHandler: completionHandler
        )

        // Pinpoint SDK will not call the `completionHandler` for you. Make sure to call `completionHandler` or your app may be terminated
        // See https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application for more details
        completionHandler(.newData)
    }
    
    //====

    ///=====
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        // Handle foreground push notifications
        logContants(of: notification)
        pinpoint?.notificationManager.interceptDidReceiveRemoteNotification(notification.request.content.userInfo, fetchCompletionHandler: { _ in })

        // Make sure to call `completionHandler`
        // See https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/1649518-usernotificationcenter for more details
        completionHandler(.badge)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)  {
        // Handle background and closed push notifications
        logContants(of: response.notification)
        pinpoint?.notificationManager.interceptDidReceiveRemoteNotification(response.notification.request.content.userInfo, fetchCompletionHandler: { _ in })

        // Make sure to call `completionHandler`
        // See https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/1649501-usernotificationcenter for more details
        completionHandler()
    }
    
    //To print the contant of notification
    func logContants(of notification: UNNotification){
        print(notification.request.content.userInfo)
    }
}
