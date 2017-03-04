//
//  RenewService.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-03-01.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation

/// A class representing functions and variables that work to execute the UPass renewal
class RenewService {
    
    // MARK: - Proporties 
    
    /// A string representing the text that the status label should show in RenewViewController
    var statusLabel:String = "" {
        didSet
        {
            // When the status label text is set, alert the view controller so the change can be displayed to the user
            NotificationCenter.default.post(name: Notification.Name("statusLabelDidChange"), object: nil)
        }
    }
    /// A string containing an integer which represents the number of UPasses the user has before the renewal attempt
    var numUpass:String?
    /// The webview object where the UPassBC website is loaded
    var webview:WebView
    /// The JSGenerator object which generates javascript to inject and run in the webview
    var jsGenerator:JSGenerator
    /// An array of completion handlers representing completion handlers for the fetch call
    var completionHandlers:[(RenewPassError?) -> Void] = []
    /// A boolean representing whether the user started the fetch in-app, or the system started the fetch in background
    static var didStartFetchFromBackground:Bool = false
    /// An account object representing the users credentials (excluding pass)
    var account:Account!
    /// A string representing the user's username
    var username:String!
    /// A school object representing the user's school
    var school:School!
    
    // MARK: - Initialization
    
    init?() {
        // Webview object
        webview = WebView()
        //Js generator object
        guard let jsGenerator = JSGenerator() else {
            return nil
        }
        self.jsGenerator = jsGenerator
    }
    
    init?(webViewFrame:CGRect) {
        // Webview object
        webview = WebView(frame: webViewFrame)
        //Js generator object
        guard let jsGenerator = JSGenerator() else {
            return nil
        }
        self.jsGenerator = jsGenerator
    }
    
    // MARK: - Public Methods
    
    func fetch(completion: @escaping (_ error:RenewPassError?) -> Void) {
        completionHandlers.append(completion)
        
        if RenewService.didStartFetchFromBackground {
            //webview = WebView()
            
            let url = URL(string: "https://upassbc.translink.ca")
            let urlRequest = URLRequest(url: url!)
            webview.loadRequest(urlRequest)
        }
        
        /*if UserDefaults.standard.bool(forKey: "showWebview") {
            self.view.addSubview(webview)
        }*/
        
        // Get the login credentials
        if account == nil {
            account = AccountManager.loadAccount()
        }
        
        guard let username = account.username as String! else {
            completionHandlers[0](RenewPassError.unknownError)
            return
        }
        
        self.username = username
        
        guard let schoolRaw = account.schoolRaw as Int16! else {
            completionHandlers[0](RenewPassError.unknownError)
            return
        }
        
        self.school = School(school: Schools(rawValue: schoolRaw)!)
        
        // If the fetch started due to user interaction, as opposed to in the background, start the renew process now
        if !RenewService.didStartFetchFromBackground {
            selectSchool()
        }
        
    }

    
    // MARK: - Private Methods
    
    func selectSchool() {
        
        statusLabel = "Selecting school"
        webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: "SelectSchool"))
        
    }

    func authenticate(school:Int16) throws {
        
        statusLabel = "Authenticating"
        guard let schoolEnum = Schools(rawValue: school) else {
            throw RenewPassError.schoolNotFoundError
        }
        let schoolObj = School(school: schoolEnum)
        
        let authenticateFileName = "Authenticate_\(schoolObj.shortName)"
        let authErrorFileName = "AuthenticationError_\(schoolObj.shortName)"
        
        let result = webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: authErrorFileName))
        if result == "failure" {
            throw RenewPassError.authenticationFailedError
        }
        
        webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: authenticateFileName))
        
        
    }

    func checkUpass() throws {
        
        guard !((webview.request?.url?.absoluteString.contains("upassadfs"))!) else {
            return
        }
        
        statusLabel = "Checking UPass"
        
        guard !(webview.request?.url?.absoluteString.contains(school.authPageURLIdentifier))! else {
            throw RenewPassError.authenticationFailedError
        }
        
        let result = webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: "CheckUPass"))
        
        guard result != "null" else {
            throw RenewPassError.alreadyHasLatestUPassError
        }
        
        numUpass = result
        
        statusLabel = "Renewing UPass"
        
        webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: "Renew"))
        
    }

    func verifyRenew() throws {
        
        if numUpass != nil {
            if let postRenewNumUpass = webview.stringByEvaluatingJavaScript(from: "document.querySelectorAll(\".status\").length")  {
                guard Int(postRenewNumUpass)! > Int(numUpass!)! else {
                    throw RenewPassError.verificationFailed
                }
                completionHandlers[0](nil)
            }
        }
        
    }

}
