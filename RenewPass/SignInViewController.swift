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
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
    }

    override func viewDidLayoutSubviews() {
        //scrollView.translatesAutoresizingMaskIntoConstraints = false
        let height = self.scrollView.contentSize.height
        self.scrollView.contentSize = CGSize(width: stackView.width, height: height)

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
        
        saveAccount(username: usernameField.text!)
        
        let keychain = KeychainSwift()
        
        if !keychain.set(passwordField.text!, forKey: "accountPassword", withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) {
            fatalError("Couldn't store in the keychain")
        }
        
        self.dismiss(animated: true) {
            
        }
        
    }

 
    // MARK: - Private methods
    private func saveAccount(username: String) {
        //1
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        //2
        let entity =  NSEntityDescription.entity(forEntityName: "Account",
                                                 in:managedContext)
        
        let account = NSManagedObject(entity: entity!,
                                     insertInto: managedContext)
        
        //3
        account.setValue(username, forKey: "username")
        account.setValue(Int16((stackView.selectedButton?.tag)!), forKey: "schoolRaw")
        
        //4
        appDelegate.saveContext()
        
    }
    
    func schoolWasSelected(notification:Notification) {
        if let selectedSchool = stackView.selectedButton?.tag {
            let school = School(school: Schools(rawValue: Int16(selectedSchool))!)
            self.usernameLabel.text = school.userNameLabel
            self.usernameField.placeholder = school.userNamePlaceHolder

        }
    }

}
