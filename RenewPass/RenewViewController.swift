//
//  RenewViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class RenewViewController: UIViewController {
    
    // MARK: - Proporties
    var accounts:[NSManagedObject]!
    var webview:UIWebView!
    var username:String!
    @IBOutlet weak var reloadButton: UIButton!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadButton.isEnabled = false
        
        // Checks if there is login data stored. If not, asks the user for login data by showing the login screen.
        if needToShowLoginScreen() {
            showLoginScreen()
        }
        
        webview = UIWebView(frame: self.view.frame)
        
        let url = URL(string: "https://upassbc.translink.ca")
        let urlRequest = URLRequest(url: url!)
        webview.loadRequest(urlRequest)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.reloadButton.isEnabled = true
            
        })

    }

    // MARK: - Navigation

    /// Displays the login screen
    func showLoginScreen() {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "signInViewController")
            
            self.present(signInViewController, animated: true) {
                
            }
        }
        
    }
    
    /// Determines if the login screen needs to be shown
    ///     Returns: A boolean describing whether to show the login screen or not
    func needToShowLoginScreen() -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            accounts = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return accounts.isEmpty
        
    }
    
    // MARK: - Actions
    
    @IBAction func renewButtonTouchUpInside(_ sender: Any) {
        self.view.addSubview(webview)
        
        let school = Schools.SFU
        
        //Get auth values
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            accounts = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        username = accounts[0].value(forKey: "username") as! String!
        
        selectSchool(school: school)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.authenticate(school: school)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.authenticate(school: school)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
                self.checkUpass()
            })
        })
        
        
        
        
        
    }
    

    func selectSchool(school:String) {
        let js = "document.querySelector(\"form\").querySelector(\"#PsiId\").options[9].selected = true; document.querySelector(\"form\").submit();"
        
        
        webview.stringByEvaluatingJavaScript(from: js)
    }
    
    func authenticate(school:String) {
        
        if school == "9" { //SFU
        
            let password = KeychainSwift().get("accountPassword")!
            
            
            let js = "document.querySelector(\"#fm1\"); document.querySelector(\"#username\").value = \"\(username!)\"; document.querySelector(\"#password\").value = \"\(password)\"; document.querySelector(\"#fm1\").submit();"
           
            webview.stringByEvaluatingJavaScript(from: js)
            

        }
        
    }
    
    func checkUpass() {
        let js = "var form = document.querySelector(\"#form-request\"); function checkUpass() { if (form.querySelector(\"[type=checkbox]\")==null){ return \"null\"} else {return \"checkbox\"} } checkUpass()"
        
        let result = webview.stringByEvaluatingJavaScript(from: js)
       
        if result == "null" {
            print("ALREADY HAS UPASS")
        }
    }


    
}
