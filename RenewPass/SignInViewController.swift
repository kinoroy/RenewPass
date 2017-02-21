//
//  SignInViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Proporties
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var accounts:[NSManagedObject]!
    @IBOutlet weak var usernameLabel: UILabel!
    var schoolSelected:UIButton!
    @IBOutlet weak var onePassButton: UIButton!
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change the nav bar text 
        self.navigationController?.title = "Sign In"
        
        // Setup delegates
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        //change username label and placeholder to corespond to school login
        let school = School(school: Schools(rawValue: Int16(schoolSelected.tag))!)
        self.usernameLabel.text = school.userNameLabel
        self.usernameField.placeholder = school.userNamePlaceHolder
        
        // Hide the Onepass button if there are no password managers enabled.
        self.onePassButton.isHidden = false//!(OnePasswordExtension.shared().isAppExtensionAvailable())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* If you're running a debug build, the login screen can auto-populate your testing login,
         put your username, password and school code (School code is the raw value of your school enum in Schools.swift), into DebugUserInfo.plist.
         
         !!!! WARNING: BEFORE MODIFYING DEBUGUSERINFO.PLIST YOU MUST RUN "git update-index --assume-unchanged DebugUserInfo.plist" TO PREVENT YOUR LOGIN INFO FROM BEING SENT TO THE REPO !!!! */
        #if DEBUG
            if let userDataPListURL = Bundle.main.url(forResource: "AutoFillInfoForDebug", withExtension: "plist"),
                let userDataFile = try? Data(contentsOf: userDataPListURL) {
                if let userDataDict = try? PropertyListSerialization.propertyList(from: userDataFile, options: [], format: nil) as? [String: Any] {
                    
                    let username = userDataDict?["Username"] as? String ?? ""
                    let password = userDataDict?["Password"] as? String ?? ""
                    
                    if !username.isEmpty && !password.isEmpty {
                        self.usernameField.text = username
                        self.passwordField.text = password
                    }
    
                }
            }
        #endif

    }
    
    // MARK: - UITextFields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    // MARK: - Navigation

    @IBAction func clickSubmitButton(_ sender: Any) {
        
        guard !(usernameField.text?.isEmpty)! && !(passwordField.text?.isEmpty)! else {
            let alert = UIAlertController(title: "Error", message: "Username and password can not be empty", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        AccountManager.saveAccount(username: usernameField.text!, password: passwordField.text!, schoolRaw: Int16((schoolSelected.tag)))
        
        self.dismiss(animated: true) {
            
        }
        
    }

    // MARK: - 1Password
    
    @IBAction func callOnePass(_ sender: Any) {
        
        let school = School(school: Schools(rawValue: Int16(schoolSelected.tag))!)
        
        OnePasswordExtension.shared().findLogin(forURLString: school.urlString, for: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary == nil {
                return
            }
            
            self.usernameField.text = loginDictionary?[AppExtensionUsernameKey] as? String
            self.passwordField.text = loginDictionary?[AppExtensionPasswordKey] as? String
        })
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
