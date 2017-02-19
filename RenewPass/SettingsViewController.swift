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
        
        // Delete account from core data 
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        
        var accounts:[NSManagedObject]!
        do {
            accounts = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        for account in accounts {
            managedContext.delete(account)
        }
        
        appDelegate.saveContext()
        
        // Delete password from keychain 
        let keychain = KeychainSwift()
        keychain.delete("accountPassword")
        
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
        
        let alert = UIAlertController(title: "Notifications", message: "RenewPass will try every month to renew your UPass in the background and notify you if successful. That cool?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Yeah!", style: .default, handler: {
            (alert:UIAlertAction) -> Void in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) {
                (granted, error) in
                if granted {
                    Answers.logCustomEvent(withName: "approvesNotifications", customAttributes: nil)
                    DispatchQueue.main.async {
                        // Disable and hide the notification button from settings 
                        self.enableNotifButton.isEnabled = false
                        self.enableNotifButton.isHidden = true
                    }
                }
            }
        })
        let NOAction = UIAlertAction(title: "No", style: .cancel, handler: {
            (alert:UIAlertAction) -> Void in
            Answers.logCustomEvent(withName: "deniesNotifications", customAttributes: nil)
        } )
        alert.addAction(OKAction)
        alert.addAction(NOAction)
        self.present(alert, animated: true)
        
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
