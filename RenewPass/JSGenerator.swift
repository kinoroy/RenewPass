//
//  JSGenerator.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-27.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation
import CoreData

class JSGenerator {
    
    // MARK: - Proporties
    
    /// An NSManagedObject representing the users account
    var account:Account
    
    // MARK: - Initialization
    init?() {
        guard let account = AccountManager.loadAccount() else {
            return nil
        }
        self.account = account
    }
    
    // MARK: - Public Methods
    func getJavaScript(filename: String) -> String {
        let path = Bundle.main.path(forResource: filename, ofType: "js")
        let url = URL(fileURLWithPath: path!)
        do {
            var js = try String(contentsOf: url, encoding: String.Encoding.utf8)
            js = js.replacingOccurrences(of: "\n", with: "")
            js = js.replacingOccurrences(of: "storedUsername", with: account.username ?? "Error")
            js = js.replacingOccurrences(of: "storedPassword", with: KeychainSwift().get("accountPassword") ?? "Error")
            js = js.replacingOccurrences(of: "_SCHOOL_ID_", with: "\(account.schoolRaw)")
            return js
        } catch {
            fatalError("Could not read the JavaScript file \"\(filename).js\"")
        }
    }
    
}
