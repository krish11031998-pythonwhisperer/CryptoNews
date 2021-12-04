//
//  NotificationTestView.swift
//  CryptoNews
//
//  Created by Krishna Venkatramani on 23/11/2021.
//

import SwiftUI
import UserNotifications

class NotificationManager{
    static let instance = NotificationManager()
    
    func requestAuthorization(){
        let options : UNAuthorizationOptions = .init(arrayLiteral: [.alert,.sound,.badge])
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, err in
            if let err = err{
                print("There was an error : ",err.localizedDescription)
            }else{
                print("Success")
            }
        }
    }
    
    
    func scheduleNotification(){
        
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = "This is my first Notification"
        content.subtitle = "This is soooo easy!"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false )
        
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
}

struct NotificationTestView: View {
    var body: some View {
        SystemButton(b_name: "bell", color: .white, haveBG: true, bgcolor: .black, alignment: .vertical) {
            NotificationManager.instance.requestAuthorization()
            NotificationManager.instance.scheduleNotification()
        }
    }
}

struct NotificationTestView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationTestView()
    }
}
