//
//  RenewPassException.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-07.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation

enum RenewPassException: Error {
    
    case authenticationFailedException
    case schoolNotFoundException
    case alreadyHasLatestUPassException
    case webViewFailedException
    case unknownException
    
}

extension RenewPassException: CustomStringConvertible {
    var title: String {
        switch self {
            
        case .authenticationFailedException:
            return "Authentication failed"
        case .schoolNotFoundException:
            return "School not supported"
        case.alreadyHasLatestUPassException:
            return "Sweet! You've snagged the latest UPass."
        case .webViewFailedException:
            return "Failed to establish a connection"
        case .unknownException:
            return "Unknown error."
            
        }
    }
    var description: String {
        switch self {
            
        case .authenticationFailedException:
            return "Authentication failed. Double check your username and password and try again."
        case .schoolNotFoundException:
            return "The school you selected is not currently supported."
        case.alreadyHasLatestUPassException:
            return "Nothing to renew: You already have the latest UPass."
        case .webViewFailedException:
            return "RenewPass failed to establish a connection. Check your internet connection. UPass and or you school's login might be down."
        case .unknownException:
            return "RenewPass encountered an unknown error."
            
        }
    }
}
