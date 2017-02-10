//
//  Strings.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-01-31.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation

public class School {
    
    // MARK: - Variables
    var school:Schools
    var longName:String {
        switch self.school {
        case .SFU:
            return "Simon Fraser University"
        case .UBC:
            return "University of British Columbia"
        case .BCIT:
            return "British Columbia Institute of Technology"
        case .VCC:
            return "Vancouver Community College"
        //case .NVIT:
            //return "Nicola Valley Institute of Technology"
        case .KPU:
            return "Kwantlen Polytechnic University"
        case .EC:
            return "Emily Carr University of Art + Design"
        case .DC:
            return "Douglas College"
        case .LC:
            return "Langara College"
        case .CU:
            return "Capilano University"
        }
    }
    var shortName:String {
        switch self.school {
        case .SFU:
            return "SFU"
        case .UBC:
            return "UBC"
        case .BCIT:
            return "BCIT"
        case .VCC:
            return "VCC"
        //case .NVIT:
            //return "NVIT"
        case .KPU:
            return "KPU"
        case .EC:
            return "EC"
        case .DC:
            return "DC"
        case .LC:
            return "LC"
        case .CU:
            return "CU"
        }
    }
    var authPageURLIdentifier:String {
        switch self.school {
        case .SFU:
            return "cas"
        case .UBC:
            return "shibboleth2"
        case .BCIT:
            return "idp"
        case .VCC:
            return "fs"
            //case .NVIT:
        //return "NVIT"
        case .KPU:
            return "idp"
        case .EC:
            return "idp"
        case .DC:
            return "federation"
        case .LC:
            return "federation"
        case .CU:
            return "fs"
        }
    }
    
    var userNameLabel:String {
        switch self.school {
        case .SFU:
            return "Computing ID"
        case .UBC:
            return "CWL Login Name"
        case .BCIT:
            return "BCIT ID (A00 NUMBER)"
        case .VCC:
            return "Student ID"
            //case .NVIT:
        //return "NVIT"
        case .KPU:
            return "Student #"
        case .EC:
            return "Username"
        case .DC:
            return "CNA ID"
        case .LC:
            return "Federated ID"
        case .CU:
            return "Cap U Email"
        }
    }
    
    // MARK: - Initialization
    
    init(school:Schools) {
        self.school = school
    }
}

// MARK: - Public methods
    
public func getSchoolID(school:Schools) -> Int16 {
    return school.rawValue
}


// MARK: - Enum
public enum Schools:Int16 {
    case SFU = 9 // Simon Fraser University
    case UBC = 4 // University of British Columbia
    case BCIT = 5// British Columbia Institute of Technology
    case VCC = 10 // Vancouver Community College
    //case NVIT = 3 // Nicola Valley Institute of Technology
    case KPU = 2 // Kwantlen Polytechnic University
    case EC = 7 // Emily Carr University of Art + Design
    case DC = 1 // Douglas College
    case LC = 8 // Langara College
    case CU = 6 // Capilano University
    
    static let orderedSchools:[Schools] = [DC,KPU,/*NVIT,*/UBC,BCIT,CU,EC,LC,SFU,VCC]
    
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

extension Schools:CustomStringConvertible {
    public var description:String {
        switch self {
        case .SFU:
            return "Simon Fraser University"
        case .UBC:
            return "University of British Columbia"
        case .BCIT:
            return "British Columbia Institute of Technology"
        case .VCC:
            return "Vancouver Community College"
        //case .NVIT:
            //return "Nicola Valley Institute of Technology"
        case .KPU:
            return "Kwantlen Polytechnic University"
        case .EC:
            return "Emily Carr University of Art + Design"
        case .DC:
            return "Douglas College"
        case .LC:
            return "Langara College"
        case .CU:
            return "Capilano University"
        }
    }
}
