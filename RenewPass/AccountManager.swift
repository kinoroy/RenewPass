//
//  AccountManager.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-16.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import os.log

class AccountManager {
    
    // MARK: - Public Methods
    
    /// Saves the username and school into an account object in core data, and the password into the iOS keychain
    /// - Parameters:
    ///     - username: A string representing the username for the user's chosen school, (could contain letters, numbers or symbols (@,. for email based school logins)
    ///     - password: A string representing the password associate with the school account
    ///     - schoolRaw: A 16-bit integer representing the school code for the user's school (Can be 1-10 inclusive)
    /// - Returns: A boolean representing whether the account was saved correctly or not
    static public func saveAccount(username: String, password:String, schoolRaw:Int16) -> Bool {
        
        // Core Data:
        
        // Get the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        // Get the managed context for CoreData
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Get the account entity from the managed context
        guard let entity =  NSEntityDescription.entity(forEntityName: "Account", in:managedContext) else {
            return false
        }
        
        // Get the account object from the core data entity
        let account = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        
        // Insert the given credentials into the account object
        account.setValue(username, forKey: "username")
        account.setValue(schoolRaw, forKey: "schoolRaw")
        
        // Save into CoreData
        appDelegate.saveContext()
        
        // Keychain:
        
        // Get the shared Keychain helper object
        let keychain = KeychainSwift()
        
        // Save the user's password in the keychain with accessibility after first unlock
        guard keychain.set(password, forKey: "accountPassword", withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) else {
            return false
        }
        
        return true
    }
    
    /// Loads the account object with username and school values from CoreData
    /// - Returns: An optional NSManagedObject representing the account, will be nil if the account couldn't be loaded
    static public func loadAccount() -> NSManagedObject? {
        
        // Get the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        // Get the managed context for CoreData
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for CoreData
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        
        // Attempt to execute the fetch request on the managed context
        do {
            let results = try managedContext.fetch(fetchRequest)
            guard results.count > 0 else {
                return nil
            }
            guard let account = results[0] as? NSManagedObject else {
                return nil
            }
            
            return account
        } catch {
            os_log("Could not fetch account information", log: .default, type: .error)
            return nil
        }
        
    }
    
    
}
