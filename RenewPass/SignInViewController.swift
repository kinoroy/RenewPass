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
    
    @IBOutlet weak var stackView: SchoolSelectorStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var accounts:[NSManagedObject]!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("schoolWasSelected"), object: nil, queue: nil, using: schoolWasSelected)
        
        NotificationCenter.default.post(name: Notification.Name("schoolWasSelected"), object: nil)
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        /* If you're running a debug build, the login screen can auto-populate your testing login, 
         put your username, password and school code (School code is the raw value of your school enum in Schools.swift), into DebugUserInfo.plist.
         
         !!!! WARNING: BEFORE MODIFYING DEBUGUSERINFO.PLIST YOU MUST RUN "git update-index --assume-unchanged DebugUserInfo.plist" TO PREVENT YOUR LOGIN INFO FROM BEING SENT TO THE REPO !!!! */
        #if DEBUG
            if let userDataPListURL = Bundle.main.url(forResource: "DebugUserInfo", withExtension: "plist"),
                let userDataFile = try? Data(contentsOf: userDataPListURL) {
                if let userDataDict = try? PropertyListSerialization.propertyList(from: userDataFile, options: [], format: nil) as? [String: Any] {

                    self.usernameField.text = userDataDict?["Username"] as? String ?? ""
                    self.passwordField.text = userDataDict?["Password"] as? String ?? ""
                    let matchingSchoolButtons = self.stackView.buttons.filter {$0.tag == userDataDict?["School Code"] as? Int ?? 1}
                    if matchingSchoolButtons.count > 0 { self.stackView.schoolSelected(sender: matchingSchoolButtons[0]) }
                }
            }
        #endif
        
    }

    override func viewDidLayoutSubviews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let height = self.stackView.frame.size.height
        self.scrollView.contentSize = CGSize(width: stackView.width * 1.05, height: height)

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
        
        AccountManager.saveAccount(username: usernameField.text!, password: passwordField.text!, schoolRaw: Int16((stackView.selectedButton?.tag)!))
        
        self.dismiss(animated: true) {
            
        }
        
    }

    // MARK: - Private methods
    
    private func schoolWasSelected(notification:Notification) {
        if let selectedSchool = stackView.selectedButton?.tag {
            let school = School(school: Schools(rawValue: Int16(selectedSchool))!)
            self.usernameLabel.text = school.userNameLabel
            self.usernameField.placeholder = school.userNamePlaceHolder

        }
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
