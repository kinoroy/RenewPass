//
//  Strings.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation


// MARK: - Public methods
    
public func getSchoolID(school:Schools) -> Int16 {
    return school.rawValue
}


// MARK: - Enum
public enum Schools:Int16 {
    case SFU = 9 // Simon Fraser University
    case UBC // University of British Columbia
    case BCIT // British Columbia Institute of Technology
    case VCC // Vancouver Community College
    case NVIT // Nicola Valley Institute of Technology
    case KPU // Kwantlen Polytechnic University
    case EC // Emily Carr University of Art + Design
    
}

// MARK: - Extensions

extension Account {
    var school: Schools {
        get {
            return Schools(rawValue: schoolRaw)!
        }
        set {
            schoolRaw = Int16(exactly: newValue.rawValue)!
        }
        
    }
}
