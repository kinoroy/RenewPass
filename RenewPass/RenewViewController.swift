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

class RenewViewController: UIViewController, CAAnimationDelegate {
    
    // MARK: - Proporties
    var accounts:[NSManagedObject]!
    var webview:WebView!
    var username:String!
    var school:School!
    var completionHandlers:[(RenewPassException) -> Void] = []
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    var numUpass:String = "0"
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
        // Checks if there is login data stored. If not, asks the user for login data by showing the login screen.
        if needToShowLoginScreen() {
            showLoginScreen()
        }
        
    }

    // MARK: - Navigation

    /// Displays the login screen
    func showLoginScreen() {
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInViewController = storyboard.instantiateViewController(withIdentifier: "signInViewController")
            
            self.present(signInViewController, animated: true) {
                
            }
        }
        
    }
    
    /// Determines if the login screen needs to be shown
    ///     Returns: A boolean describing whether to show the login screen or not
    func needToShowLoginScreen() -> Bool {
        
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
        
        return accounts.isEmpty
        
    }
    
    // MARK: - Actions
    
    @IBAction func renewButtonTouchUpInside(_ sender: Any) {
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
                print("\(error)")
            } else {
                self.statusLabel.text = "You don't have the latest UPass."
            }
            self.webview.removeFromSuperview()
        }
        
        
    }
    
    func selectSchool(school:Int16) {
        
        statusLabel.text = "Selecting school"
        webview.stringByEvaluatingJavaScript(from: getJavaScript(filename: "SelectSchool"))

    }
    
    func authenticate(school:Int16) throws {
        
        statusLabel.text = "Authenticating"
        guard let schoolEnum = Schools(rawValue: school) else {
            throw RenewPassException.schoolNotFoundException
        }
        let schoolObj = School(school: schoolEnum)
        
        let authenticateFileName = "Authenticate_\(schoolObj.shortName)"
        let authErrorFileName = "AuthenticationError_\(schoolObj.shortName)"
        
        let result = webview.stringByEvaluatingJavaScript(from: getJavaScript(filename: authErrorFileName))
        if result == "failure" {
            throw RenewPassException.authenticationFailedException
        }
        
        webview.stringByEvaluatingJavaScript(from: getJavaScript(filename: authenticateFileName))
        
        
    }
    
    func checkUpass() throws {
        
        statusLabel.text = "Checking UPass"
        
        guard !(webview.request?.url?.absoluteString.contains(school.authPageURLIdentifier))! else {
            throw RenewPassException.authenticationFailedException
        }
        
        let result = webview.stringByEvaluatingJavaScript(from: getJavaScript(filename: "CheckUPass"))
       
        guard result != "null" else {
            throw RenewPassException.alreadyHasLatestUPassException
        }
        
        statusLabel.text = "Renewing UPass"
        
        webview.stringByEvaluatingJavaScript(from: getJavaScript(filename: "Renew"))
    }


    func getJavaScript(filename: String) -> String {
        let path = Bundle.main.path(forResource: filename, ofType: "js")
        let url = URL(fileURLWithPath: path!)
        do {
            var js = try String(contentsOf: url, encoding: String.Encoding.utf8)
            js = js.replacingOccurrences(of: "\n", with: "")
            js = js.replacingOccurrences(of: "storedUsername", with: username)
            js = js.replacingOccurrences(of: "storedPassword", with: KeychainSwift().get("accountPassword")! as String)
            js = js.replacingOccurrences(of: "_SCHOOL_ID_", with: "\(getSchoolID(school: school.school))")
            js = js.replacingOccurrences(of: "PREV_NUM_UPASS", with: numUpass)
            return js
        } catch {
            fatalError("Could not read the JavaScript file \"\(filename).js\"")
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
                try checkUpass()
            }
        } catch let error as RenewPassException {
            statusLabel.text = error.title
            completionHandlers[0](error)
        } catch {
            statusLabel.text = "Unknown Error"
            completionHandlers[0](RenewPassException.unknownException)
        }
        
    }
    
    func webViewDidFailLoadWithError(notification:Notification) {
        completionHandlers[0](RenewPassException.webViewFailedException)
    }
    
    func fetch(completion: @escaping (_ error:RenewPassException?) -> Void) {
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
        
        //Get auth values
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
        
        username = accounts[0].value(forKey: "username") as! String!
        
        let schoolRaw:Int16 = accounts[0].value(forKey: "SchoolRaw") as! Int16
        
        school = School(school: Schools(rawValue: schoolRaw)!)
        
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

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate as? CAAnimationDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
