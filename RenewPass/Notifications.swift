//
//  Notifications.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-03-03.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation
import Crashlytics
import UserNotifications

class Notifications {
    
    static func requestNotificationAuthorization(viewControllerToPresent: UIViewController) {
        
        
        let alert = UIAlertController(title: "Notifications", message: "RenewPass will try every month to renew your UPass in the background and notify you if successful. That cool?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Yeah!", style: .default, handler: {
            (alert:UIAlertAction) -> Void in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) {
                (granted, error) in
                if granted {
                    Answers.logCustomEvent(withName: "approvesNotifications", customAttributes: nil)
                }
            }
        })
        let NOAction = UIAlertAction(title: "No", style: .cancel, handler: {
            (alert:UIAlertAction) -> Void in
            Answers.logCustomEvent(withName: "deniesNotifications", customAttributes: nil)
        } )
        alert.addAction(OKAction)
        alert.addAction(NOAction)
        viewControllerToPresent.present(alert, animated: true) {
            UserDefaults.standard.set(true, forKey: "hasAskedUserForNotifAuth")
        }
    }
    
    
}
