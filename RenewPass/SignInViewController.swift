//
//  SignInViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController {
    
    // MARK: - Proporties
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var accounts:[NSManagedObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if !accounts.isEmpty {
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "submitSegue", sender: nil)
            }
            
        }
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitSegue" {
            
            saveAccount(username: usernameField.text!)
            
            let keychain = KeychainSwift()
            
            if !keychain.set(passwordField.text!, forKey: "accountPassword") {
                fatalError("Couldn't store in the keychain")
            }
            
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
        account.setValue(Schools.SFU, forKey: "school")
        
        //4
        appDelegate.saveContext()
    }
    

}
