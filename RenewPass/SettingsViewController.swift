//
//  SettingsViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    // MARK: - Proporties 
    
    @IBOutlet weak var showWebviewSwitch: UISwitch!
    @IBOutlet weak var showWebViewLabel: UILabel!
    
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        showWebviewSwitch.isOn = UserDefaults.standard.bool(forKey: "showWebview")
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
