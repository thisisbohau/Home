//
//  NotificationCentre.swift
//  Home
//
//  Created by David Bohaumilitzky on 08.05.21.
//

import Foundation
import UserNotifications

class notifications: ObservableObject{
    @Published var authorizationStatus: Bool = false
    let notificationCentre = UNUserNotificationCenter.current()
    
    func requestAuthorization(){
        
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        notificationCentre.requestAuthorization(options: authOptions){(success, error) in
            if let error = error{
                print("Notification authorization failed with errors: \(error)")
            }
            print("Authorization status: \(success.description)")
            self.authorizationStatus = true
        }
    }
    
    func getAuthorizationStatus(){
        notificationCentre.getNotificationSettings(){ [self](settings) in
            if settings.authorizationStatus == .authorized{
                authorizationStatus = true
            }else{
                requestAuthorization()
//                authorizationStatus = false
            }
        }
    }
    
    func invalidateNotificationForId(id: String){
        notificationCentre.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func scheduleNotification(id: String, date: Date, title: String, body: String){
        let triggerDate = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request){(error) in
            if let error = error{
                print("scheduling notification failed with errors: \(error.localizedDescription))")
            }
        }
    }
    func sendNotificationWithContent(id: String, inSeconds: Int, title: String, content: String){
//        notificationCentre.removeAllDeliveredNotifications()
        getAuthorizationStatus()
        
        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.body = content
        notification.badge = NSNumber(value: 0)
        notification.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(inSeconds), repeats: false)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notification, trigger: trigger)
        notificationCentre.add(request){ (error) in
            if let error = error{
                print("sending notification failed with errors:\(error)")
            }
           
        }
    }
}
