//
//  SignInViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Proporties
    
    @IBOutlet weak var pickerview: UIPickerView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var accounts:[NSManagedObject]!
    let schools = ["SFU"]
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerview.delegate = self
        pickerview.dataSource = self
        // Do any additional setup after loading the view.
    }

    // MARK: - Pickerview 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row]
    }
    
    // MARK: - Navigation

    @IBAction func clickSubmitButton(_ sender: Any) {
        
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
        account.setValue(schoolForPickerView(row: pickerview.selectedRow(inComponent: 0)), forKey: "schoolRaw")
        
        //4
        appDelegate.saveContext()
        
    }
    
    private func schoolForPickerView(row:Int) -> Int16 {
        switch row {
        case 0:
            return Schools.SFU.rawValue
        default:
            return 0
        }
    }
    

}
