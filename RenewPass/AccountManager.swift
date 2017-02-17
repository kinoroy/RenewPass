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

class AccountManager {
    
    // MARK: - Public Methods
    
    static public func saveAccount(username: String, password:String, schoolRaw:Int16) {
        // Save username and school through CoreData
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Account",
                                                 in:managedContext)
        
        let account = NSManagedObject(entity: entity!,
                                      insertInto: managedContext)
        
        
        account.setValue(username, forKey: "username")
        account.setValue(schoolRaw, forKey: "schoolRaw")
        
        
        appDelegate.saveContext()
        
        // Save password through keychain 
        let keychain = KeychainSwift()
        
        if !keychain.set(password, forKey: "accountPassword", withAccess: KeychainSwiftAccessOptions.accessibleAfterFirstUnlock) {
            fatalError("Couldn't store in the keychain")
        }
        
    }
    
}
