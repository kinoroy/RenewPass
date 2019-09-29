//
//  SchoolCollectionViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-20.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit

private let reuseIdentifier = "schoolButton"

class SchoolCollectionViewController: UICollectionViewController {

    // MARK: - Proporties 
    var buttons:[UIButton] = []
    var selectedButton:UIButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change the nav bar text
        self.navigationController?.title = "Select Your School"

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /* If you're running a debug build, the login screen can auto-populate your testing login,
         create a PLIST called "AutoFillInfoForDebug.plist" with the following key-value pairs:
         <key>Username</key>
         <string>Your Username Here</string>
         <key>Password</key>
         <string>Your Password Here</string>
         <key>School Code</key>
         <integer>The integer that represents your school enum (see Schools.swift for your school code) </integer>
         put your username, password and school code (School code is the raw value of your school enum in Schools.swift), into DebugUserInfo.plist.
         
         WARNING: GITIGNORE THIS FILE IMMEDIATELY, TO PREVENT ACCIDENTLY COMMITING YOUR LOGIN INFO TO THE REPO */
        
        #if DEBUG
            if let userDataPListURL = Bundle.main.url(forResource: "AutoFillInfoForDebug", withExtension: "plist"),
                let userDataFile = try? Data(contentsOf: userDataPListURL) {
                if let userDataDict = ((try? PropertyListSerialization.propertyList(from: userDataFile, options: [], format: nil) as? [String: Any]) as [String : Any]??) {
                    
                    let matchingSchoolButtons = self.buttons.filter {$0.tag == userDataDict?["School Code"] as? Int ?? 1}
                    if matchingSchoolButtons.count > 0 { self.schoolSelected(sender: matchingSchoolButtons[0]) }
                }
            }
        #endif
    }
    

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Schools.orderedSchools.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schoolButton", for: indexPath)
        
        let schoolObj = School(school: Schools.orderedSchools[indexPath.row])
        let unSelectedimage = UIImage(named: "\(schoolObj.shortName)_unchecked")
        
        let frame = CGRect(x: 0 , y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        
        let button = UIButton(frame: frame)
        button.setImage(unSelectedimage, for: .normal)
        //button.setImage(selectedimage, for: .selected)
        button.tag = Int(schoolObj.school.rawValue)
        button.addTarget(self, action: #selector(schoolSelected), for: .touchUpInside)
        
        buttons.append(button)
        
        cell.contentView.addSubview(button)
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView?.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.subviews[0].alpha = 0.5
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - Private methods
    
    @objc func schoolSelected(sender: UIButton) {
        // If there is any current school selected, de-select it
        if selectedButton != nil {
            selectedButton?.isSelected = false
        }
        
        // Now select the new school button
        DispatchQueue.main.async {
            sender.isSelected = !sender.isSelected
        }
        
        selectedButton = sender
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "signInViewController") as! SignInViewController
        signInViewController.schoolSelected = selectedButton
        
        self.navigationController?.pushViewController(signInViewController, animated: true)
        
    }

    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
