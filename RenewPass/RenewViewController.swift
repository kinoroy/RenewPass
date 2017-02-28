//
//  RenewViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData
import WebKit
import os.log
import Crashlytics
import UserNotifications

class RenewViewController: UIViewController, CAAnimationDelegate {
    
    // MARK: - Proporties
    var account:Account!
    var webview:WebView!
    var username:String!
    var school:School!
    var jsGenerator:JSGenerator!
    var completionHandlers:[(RenewPassError?) -> Void] = []
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    var numUpass:String?
    var didStartFetchFromBackground:Bool = false
    var shouldContinueReloadAnimation:Bool = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.text = "Connecting to Translink. Just a moment."
        
        NotificationCenter.default.addObserver(forName: Notification.Name("webViewDidFinishLoad"), object: nil, queue: nil, using: webViewDidFinishLoad)
        NotificationCenter.default.addObserver(forName: Notification.Name("webViewDidFailLoadWithError"), object: nil, queue: nil, using: webViewDidFailLoadWithError)
        
        self.reloadButton.isEnabled = false
        
        if !didStartFetchFromBackground {
            webview = WebView(frame: self.view.frame)
            
            let url = URL(string: "https://upassbc.translink.ca")
            let urlRequest = URLRequest(url: url!)
            webview.loadRequest(urlRequest)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reset the reload button image
        self.reloadButton.setImage(#imageLiteral(resourceName: "requestButton"), for: .normal)
        // Checks if there is login data stored. If not, asks the user for login data by showing the login screen.
        if needToShowLoginScreen() {
            showLoginScreen()
        } else {
            // If the user has not been prompted to enable notifications, ask them now.
            if !UserDefaults.standard.bool(forKey: "hasAskedUserForNotifAuth") {
                let alert = UIAlertController(title: "Notifications", message: "RenewPass will try every month to renew your UPass in the background and notify you if successful. That cool?", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Yeah!", style: .default, handler: {
                    (alert:UIAlertAction) -> Void in
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) {
                        (granted, error) in
                        if granted {
                            Answers.logCustomEvent(withName: "approvesNotifications", customAttributes: nil)
                        }
                    }
                })
                let NOAction = UIAlertAction(title: "No", style: .cancel, handler: {
                (alert:UIAlertAction) -> Void in
                    Answers.logCustomEvent(withName: "deniesNotifications", customAttributes: nil)
                } )
                alert.addAction(OKAction)
                alert.addAction(NOAction)
                self.present(alert, animated: true) {
                UserDefaults.standard.set(true, forKey: "hasAskedUserForNotifAuth")
                }
            }
            
            //Js generator object
            jsGenerator = JSGenerator()
        }
    }

    // MARK: - Navigation

    /// Displays the login screen
    func showLoginScreen() {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "schoolCollectionNavigationController")
            
            self.present(signInViewController, animated: true) {
                
            }
        }
        
    }
    
    /// Determines if the login screen needs to be shown
    ///     Returns: A boolean describing whether to show the login screen or not
    func needToShowLoginScreen() -> Bool {
        
        // If the account can not be loaded or doesn't exist, we have to show the login screen
        guard let account = AccountManager.loadAccount() as Account! else {
            return true
        }
        
        // Get the account object
        self.account = account
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func renewButtonTouchUpInside(_ sender: Any) {
        // Reset the reload button image
        self.reloadButton.setImage(#imageLiteral(resourceName: "requestButton"), for: .normal)
        numUpass = nil
        reloadButton.isEnabled = false
        shouldContinueReloadAnimation = true
        reloadButton.rotate360Degrees(completionDelegate: self)
        
        statusLabel.text = "Selecting School"
        
        fetch() { (error) in
            self.shouldContinueReloadAnimation = false
            
            let url = URL(string: "https://upassbc.translink.ca")
            let urlRequest = URLRequest(url: url!)
            self.webview.loadRequest(urlRequest)
            
            if error != nil {
                if error == RenewPassError.alreadyHasLatestUPassError {
                    os_log("Already has the latest UPass", log: .default, type: .debug)
                    self.reloadButton.setImage(#imageLiteral(resourceName: "Checkmark"), for: .normal)
                } else {
                    Answers.logCustomEvent(withName: "RenewPassError", customAttributes: ["Error":"\(error!.title)","School":self.school.shortName])
                    self.reloadButton.setImage(#imageLiteral(resourceName: "Error"), for: .normal)
                }
            } else {
                self.statusLabel.text = "Sweet! You've snagged the latest UPass."
                self.reloadButton.setImage(#imageLiteral(resourceName: "Checkmark"), for: .normal)
            }
            self.webview.removeFromSuperview()
        }
        
        
    }
    
    func selectSchool(school:Int16) {
        
        statusLabel.text = "Selecting school"
        webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: "SelectSchool"))

    }
    
    func authenticate(school:Int16) throws {
        
        statusLabel.text = "Authenticating"
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
        
        statusLabel.text = "Checking UPass"
        
        guard !(webview.request?.url?.absoluteString.contains(school.authPageURLIdentifier))! else {
            throw RenewPassError.authenticationFailedError
        }
        
        let result = webview.stringByEvaluatingJavaScript(from: jsGenerator.getJavaScript(filename: "CheckUPass"))
       
        guard result != "null" else {
            throw RenewPassError.alreadyHasLatestUPassError
        }
        
        numUpass = result
        
        statusLabel.text = "Renewing UPass"
        
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
    
    // MARK: - Webview
    func webViewDidFinishLoad(notification:Notification) {
        //let webView = notification.object as! UIWebView
        guard let currentURL = webview.request?.url?.absoluteString else {
            fatalError("Webview did not load a URL")
        }
        
        do {
            if currentURL == "https://upassbc.translink.ca/" {
                reloadButton.isEnabled = true
                if statusLabel.text == "Connecting to Translink. Just a moment." {
                    statusLabel.text = "Click away!"
                }
                
                if didStartFetchFromBackground {
                    selectSchool(school: getSchoolID(school: school.school))
                }
            } else if currentURL.contains(school.authPageURLIdentifier) { // School authentication screen
                try authenticate(school: getSchoolID(school: school.school))
            } else if currentURL.contains("fs") { // post-auth Upass site
                if numUpass == nil {
                    try checkUpass()
                } else {
                    try verifyRenew()
                }
                
            }
        } catch let error as RenewPassError {
            statusLabel.text = error.title
            completionHandlers[0](error)
        } catch {
            statusLabel.text = "Unknown Error"
            completionHandlers[0](RenewPassError.unknownError)
        }
        
    }
    
    func webViewDidFailLoadWithError(notification:Notification) {
        completionHandlers[0](RenewPassError.webViewFailedError)
    }
    
    func fetch(completion: @escaping (_ error:RenewPassError?) -> Void) {
        completionHandlers.append(completion)
        
        if didStartFetchFromBackground {
            webview = WebView(frame: self.view.frame)

            let url = URL(string: "https://upassbc.translink.ca")
            let urlRequest = URLRequest(url: url!)
            webview.loadRequest(urlRequest)
        }
        
        if UserDefaults.standard.bool(forKey: "showWebview") {
            self.view.addSubview(webview)
        }
        
        // Get the login credentials 
        
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
        if !didStartFetchFromBackground {
            selectSchool(school: getSchoolID(school: school.school))
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
    
    // MARK: - CAAnimation
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if shouldContinueReloadAnimation {
            self.reloadButton.rotate360Degrees(completionDelegate: self)
        }
    }
    
}
