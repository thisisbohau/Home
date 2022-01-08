//
//  HomeApp.swift
//  Home
//
//  Created by David Bohaumilitzky on 23.04.21.
//

import SwiftUI
import Firebase
import Foundation


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    let gcmMessageIDKey = "gcm.message_id"
    

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        BackgroundSession.shared.savedCompletionHandler = completionHandler
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        let network = NetworkStatus.shared
        network.start()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print(userInfo)
        completionHandler([[.banner, .badge, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print(userInfo)
        
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken;
    }
    
    func didReceive(_ request: UNNotificationRequest,
                    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void){
        print("request received")
    }
}

extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token), this token will be saved in the users keychain")
                //save the FCM token in userdefaults
                let _ = Keychain.save(key: "FCMToken", data: token.data(using: .utf8) ?? Data())
//                UserDefaults.standard.set(token, forKey: "FCMToken")
                
                Messaging.messaging().subscribe(toTopic: "home") { error in
                    print("Subscribed to home topic")
                }
            }
        }
    }
}

@main
struct HomeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sceneKit = SceneKit()
    var updater = UpdateManager()
    var appState = AppState()
    
    @StateObject var locationManager = LocationManager()
    @State var showDeviceSetup: Bool = false
    


    var body: some Scene {
        WindowGroup {
            MainMenu()
                .preferredColorScheme(.dark)
                .onAppear(perform: {updater.startUpdateLoop()})
                .environmentObject(updater)
                .environmentObject(appState)
                .environmentObject(sceneKit)
        }
    }
    
}



