//
//  AppDelegate.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData
import os.log
import Fabric
import Crashlytics
import UserNotifications
import AWSCore
import AWSSNS
import AWSCognito
//import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    #if DEBUG
        let SNSPlatformApplicationArn = "arn:aws:sns:us-east-1:081073680324:app/APNS_SANDBOX/RenewPass"
    #else
        let SNSPlatformApplicationArn = "arn:aws:sns:us-east-1:081073680324:app/APNS/RenewPass"
    #endif
    let SNSTopicArn = "arn:aws:sns:us-east-1:081073680324:renewPass"
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setup Crashlytics 
        #if DEBUG
            Fabric.sharedSDK().debug = true
        #endif
        Fabric.with([Crashlytics.self])
        
        // Check version with Siren
        //let siren = Siren.sharedInstance
        
        // Siren will ask users to update
        //siren.alertType = .option
        
        /*
         Replace .Immediately with .Daily or .Weekly to specify a maximum daily or weekly frequency for version
         checks.
         */
        //siren.checkVersion(checkType: .immediately)
        
        /*// Setup Siren loging on debug builds
        #if DEBUG
            siren.debugEnabled = true
        #endif*/
        // Logging
        AWSDDLog.sharedInstance.logLevel = AWSDDLogLevel.verbose
        
        // Initialize the Amazon Cognito credentials provider
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:"us-east-1:e5a72c13-00d3-42f2-85ab-17d582ab573b")
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch(settings.authorizationStatus) {
            
            case .notDetermined:
                break
            case .denied:
                break
            case .authorized, .provisional:
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        /*
         Replace .Immediately with .Daily or .Weekly to specify a maximum daily or weekly frequency for version
         checks.
         */
        //Siren.sharedInstance.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RenewPass")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    /*func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        os_log("Performing a background fetch", log: .default, type: .debug)
        RenewService.didStartFetchFromBackground = true
        //let renewService = RenewService()!
        let renewService = RenewService.getInstance()
        renewService.fetch() {
            (error) in
            RenewService.didStartFetchFromBackground = false // Resets the fetch value
            if error != nil {
                
                if error == RenewPassError.alreadyHasLatestUPassError {
                    os_log("Already has the latest UPass", log: .default, type: .debug)
                } else {
                    Answers.logCustomEvent(withName: "RenewPassError", customAttributes: ["Error":"\(error!.title)","School":renewService.school.shortName])
                }
                completionHandler(UIBackgroundFetchResult.noData)

            } else {
                os_log("We got the latest UPass!", log: .default, type: .debug)
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "You've Snagged the Latest UPass!"
                notificationContent.body = "RenewPass successfully renewed your UPass for next month. Happy riding!"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                
                let request = UNNotificationRequest(identifier: "newUPassFromBackground", content: notificationContent, trigger: trigger)
                UNUserNotificationCenter.current().add(request) {
                    (error) in
                    if error != nil {
                        os_log("Unable to schedule renewal notification", log: .default, type: .error)
                    }
                }
                completionHandler(UIBackgroundFetchResult.newData)
            }
        }
    }*/
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var tokenNoSpaces = ""
        for i in 0..<deviceToken.count {
            tokenNoSpaces = tokenNoSpaces + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(tokenNoSpaces)
        UserDefaults.standard.set(tokenNoSpaces, forKey: "deviceTokenForSNS")
        
        /// device endpoint ARN
        let sns = AWSSNS.default()
        let request = AWSSNSCreatePlatformEndpointInput()
        request?.token = tokenNoSpaces
        request?.platformApplicationArn = SNSPlatformApplicationArn
        sns.createPlatformEndpoint(request!).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
            } else {
                let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                if let endpointArnForSNS = createEndpointResponse.endpointArn {
                    print("endpointArn: \(endpointArnForSNS)")
                    if let subIn = AWSSNSSubscribeInput() {
                        subIn.endpoint = endpointArnForSNS
                        subIn.protocols = "application"
                        subIn.topicArn = self.SNSTopicArn
                        print("SUBSCRIBING TO TOPIC")
                        sns.subscribe(subIn).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject!
                            in
                            if task.error != nil {
                                print("Error: \(String(describing: task.error))")
                            } else {
                                print("Subbed to topic")
                            }
                            return nil
                        })
                    }
                    UserDefaults.standard.set(endpointArnForSNS, forKey: "endpointArnForSNS")
                }
            }
            
            return nil
        })
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }

}

