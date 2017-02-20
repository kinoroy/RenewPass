//
//  SignInViewController.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Proporties
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var accounts:[NSManagedObject]!
    @IBOutlet weak var usernameLabel: UILabel!
    var buttons:[UIButton] = []
    var selectedButton:UIButton? = nil
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        /* If you're running a debug build, the login screen can auto-populate your testing login,
         put your username, password and school code (School code is the raw value of your school enum in Schools.swift), into DebugUserInfo.plist.
         
         !!!! WARNING: BEFORE MODIFYING DEBUGUSERINFO.PLIST YOU MUST RUN "git update-index --assume-unchanged DebugUserInfo.plist" TO PREVENT YOUR LOGIN INFO FROM BEING SENT TO THE REPO !!!! */
        #if DEBUG
            if let userDataPListURL = Bundle.main.url(forResource: "DebugUserInfo", withExtension: "plist"),
                let userDataFile = try? Data(contentsOf: userDataPListURL) {
                if let userDataDict = try? PropertyListSerialization.propertyList(from: userDataFile, options: [], format: nil) as? [String: Any] {
                    
                    self.usernameField.text = userDataDict?["Username"] as? String ?? ""
                    self.passwordField.text = userDataDict?["Password"] as? String ?? ""
                    let matchingSchoolButtons = self.buttons.filter {$0.tag == userDataDict?["School Code"] as? Int ?? 1}
                    if matchingSchoolButtons.count > 0 { self.schoolSelected(sender: matchingSchoolButtons[0]) }
                }
            }
        #endif

    }
    
    // MARK: - UITextFields
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    // MARK: - Navigation

    @IBAction func clickSubmitButton(_ sender: Any) {
        
        guard !(usernameField.text?.isEmpty)! && !(passwordField.text?.isEmpty)! else {
            let alert = UIAlertController(title: "Error", message: "Username and password can not be empty", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
            return
        }
        
        AccountManager.saveAccount(username: usernameField.text!, password: passwordField.text!, schoolRaw: Int16((self.selectedButton?.tag)!))
        
        self.dismiss(animated: true) {
            
        }
        
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Schools.orderedSchools.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "schoolCell", for: indexPath)
        
        let schoolObj = School(school: Schools.orderedSchools[indexPath.row])
        let unSelectedimage = UIImage(named: "\(schoolObj.shortName)_unchecked")
        let selectedimage = UIImage(named: "\(schoolObj.shortName)_checked")
        let frame = CGRect(x: 0 , y: 0, width: cell.frame.size.width, height: cell.frame.size.height)
        
        let button = UIButton(frame: frame)
        button.setImage(unSelectedimage, for: .normal)
        button.setImage(selectedimage, for: .selected)
        button.tag = Int(schoolObj.school.rawValue)
        button.addTarget(self, action: #selector(schoolSelected), for: .touchUpInside)
        
        buttons.append(button)

        cell.contentView.addSubview(button)
        
        return cell
    }

    // MARK: - Private methods
    
    func schoolSelected(sender: UIButton) {
        // If there is any current school selected, de-select it
        if selectedButton != nil {
            selectedButton?.isSelected = false
        }
        
        // Now select the new school button
        DispatchQueue.main.async {
            sender.isSelected = !sender.isSelected
        }
        selectedButton = sender
        
        let school = School(school: Schools(rawValue: Int16(sender.tag))!)
        self.usernameLabel.text = school.userNameLabel
        self.usernameField.placeholder = school.userNamePlaceHolder
            
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
