//
//  SettingsViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics
import UserNotifications

class SettingsViewController: UIViewController {
    
    // MARK: - Proporties 
    
    @IBOutlet weak var showWebviewSwitch: UISwitch!
    @IBOutlet weak var showWebViewLabel: UILabel!
    @IBOutlet weak var enableNotifButton: UIButton!
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showWebviewSwitch.isOn = UserDefaults.standard.bool(forKey: "showWebview")
        
        let notifAuth = UIApplication.shared.currentUserNotificationSettings
        
        if (notifAuth?.types.contains(.alert))! {
            enableNotifButton.isHidden = true
        } else {
            enableNotifButton.addTarget(self, action: #selector(requestNotifAuth), for: .touchUpInside)
        }
        
        // Show the debug menu if the build is debug
        #if DEBUG
            showWebviewSwitch.isHidden = false
            showWebViewLabel.isHidden = false
            showWebViewLabel.adjustsFontSizeToFitWidth = true
        #endif
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func clickResetAccountButton(_ sender: Any) {
        
        // Delete account data and password data
        _ = AccountManager.deleteAccount()
        
        // Sends user back to login screen immediately
        _ = navigationController?.popViewController(animated: true)

        
    }
    
    
    @IBAction func showWebviewSwitchValueChanged(_ sender: Any) {
        if let webviewSwitch = sender as? UISwitch {
            if webviewSwitch.isOn {
                UserDefaults.standard.set(true, forKey: "showWebview")
            } else {
                UserDefaults.standard.set(false, forKey: "showWebview")
            }
        }
    }
    
    // MARK: - Internal methods 
    
    internal func requestNotifAuth() {
        
        Notifications.requestNotificationAuthorization(viewControllerToPresent: self)
        
    }
    
    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

}
