//
//  SignInViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData

/// The view controller which represents the login screen of the app
class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Proporties
    
    /// The username field of the login screen
    @IBOutlet weak var usernameField: UITextField!
    /// The password field of the login screen
    @IBOutlet weak var passwordField: UITextField!
    /// The label which describes the type of input for the username field
    @IBOutlet weak var usernameLabel: UILabel!
    /// The button which represents the school the user chose in the school selection view
    var schoolSelected:UIButton!
    /// A button which brings up a list of password managers
    @IBOutlet weak var onePassButton: UIButton!
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change the nav bar text from "Select School" to "Sign In"
        self.navigationController?.title = "Sign In"
        
        // Setup delegates
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        //Change username label and placeholder to corespond to school login
        let school = School(school: Schools(rawValue: Int16(schoolSelected.tag))!)
        self.usernameLabel.text = school.userNameLabel
        self.usernameField.placeholder = school.userNamePlaceHolder
        
        // Hide the Onepass button if there are no password managers enabled.
        self.onePassButton.isHidden = false//!(OnePasswordExtension.shared().isAppExtensionAvailable())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* If you're running a debug build, the login screen can auto-populate your testing login,
         create a PLIST called "AutoFillInfoForDebug.plist" with the following key-value pairs:
         <key>Username</key>
         <string>Your Username Here</string>
         <key>Password</key>
         <string>Your Password Here</string>
         <key>School Code</key>
         <integer>The integer that represents your school enum (see Schools.swift for your school code) </integer>
         put your username, password and school code (School code is the raw value of your school enum in Schools.swift), into DebugUserInfo.plist.
         
         WARNING: GITIGNORE THIS FILE IMMEDIATELY, TO PREVENT ACCIDENTLY COMMITING YOUR LOGIN INFO TO THE REPO */
        
        #if DEBUG
            if let userDataPListURL = Bundle.main.url(forResource: "AutoFillInfoForDebug", withExtension: "plist"),
                let userDataFile = try? Data(contentsOf: userDataPListURL) {
                if let userDataDict = ((try? PropertyListSerialization.propertyList(from: userDataFile, options: [], format: nil) as? [String: Any]) as [String : Any]??) {
                    
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
        // Dismiss the keyboard when the user hits return
        textField.endEditing(true)
        return false
    }
    
    // MARK: - Navigation

    /// Called when the user clicks the submit button on the login screen
    @IBAction func clickSubmitButton(_ sender: Any) {
        
        // Asset the username and password fields are both not empty before continuing
        // otherwise, display an error message and do not continue
        guard !(usernameField.text?.isEmpty)! && !(passwordField.text?.isEmpty)! else {
            let alert = UIAlertController(title: "Error", message: "Username and password can not be empty", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        // Save the username, password, and selected school into CoreData
        // If the account manager reports the either CoreData or Keychain couldn't save the credentials, the app will crash
        guard AccountManager.saveAccount(username: usernameField.text!, password: passwordField.text!, schoolRaw: Int16((schoolSelected.tag))) else {
            fatalError("Couldn't save account data")
        }
        
        // Dismiss the sign-in screen
        self.dismiss(animated: true) {
            
        }
        
    }

    // MARK: - 1Password
    
    /// Calls the One-Password extension when the user clicks the one-password button
    @IBAction func callOnePass(_ sender: Any) {
        
        // Create a school object from the selected school
        let school = School(school: Schools(rawValue: Int16(schoolSelected.tag))!)
        
        // Call the One-Password extension to show an action sheet with possible password managers
        OnePasswordExtension.shared().findLogin(forURLString: school.urlString, for: self, sender: sender, completion: { (loginDictionary, error) -> Void in
            if loginDictionary == nil {
                return
            }
            
            // Get the username and password from the password manager
            self.usernameField.text = loginDictionary?[AppExtensionUsernameKey] as? String
            self.passwordField.text = loginDictionary?[AppExtensionPasswordKey] as? String
        })
    }
    

    // MARK: - Status Bar
    // Hide the status bar on debug builds
    override var prefersStatusBarHidden: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
