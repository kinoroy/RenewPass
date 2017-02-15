//
//  SchoolSelectorStackView.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-13.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import UIKit

class SchoolSelectorStackView: UIStackView {

    // MARK: - Proporties
    var buttons:[UIButton] = []
    var width:CGFloat = 0.0
    var selectedButton:UIButton? = nil
    
    // MARK: - Life Cycle 
    
    override func layoutSubviews() {
        //translatesAutoresizingMaskIntoConstraints = false
        setupSchools()
        let newFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
        self.frame = newFrame
        schoolSelected(sender: buttons[0])
    }
    
    // MARK: - Private Methods
    
    private func setupSchools() {
        for school in Schools.orderedSchools {
            let schoolObj = School(school: school)
            let unSelectedimage = UIImage(named: "\(schoolObj.shortName)_unchecked")
            let selectedimage = UIImage(named: "\(schoolObj.shortName)_checked")
            let frame = CGRect(x: CGFloat(buttons.count) * 1.05 * (selectedimage?.size.width)! , y: 0, width: (selectedimage?.size.width)!, height: (selectedimage?.size.height)!)
            
            let button = UIButton(frame: frame)
            button.setImage(unSelectedimage, for: .normal)
            button.setImage(selectedimage, for: .selected)
            button.tag = Int(school.rawValue)
            button.addTarget(self, action: #selector(schoolSelected), for: .touchUpInside)
            
            buttons.append(button)
            
            self.addSubview(button)
            width += frame.size.width
        }
    }

    func schoolSelected(sender: UIButton) {
        if selectedButton != nil {
            selectedButton?.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        selectedButton = sender
        NotificationCenter.default.post(name: Notification.Name("schoolWasSelected"), object: nil)
    }
}
