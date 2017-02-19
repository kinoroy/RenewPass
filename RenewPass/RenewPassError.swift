//
//  RenewPassError.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-07.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation

enum RenewPassError: Error {
    
    case authenticationFailedError
    case schoolNotFoundError
    case alreadyHasLatestUPassError
    case webViewFailedError
    case unknownError
    
}

extension RenewPassError: CustomStringConvertible {
    var title: String {
        switch self {
            
        case .authenticationFailedError:
            return "Authentication failed"
        case .schoolNotFoundError:
            return "School not supported"
        case.alreadyHasLatestUPassError:
            return "Sweet! You've snagged the latest UPass."
        case .webViewFailedError:
            return "Failed to establish a connection"
        case .unknownError:
            return "Unknown error."
            
        }
    }
    var description: String {
        switch self {
            
        case .authenticationFailedError:
            return "Authentication failed. Double check your username and password and try again."
        case .schoolNotFoundError:
            return "The school you selected is not currently supported."
        case.alreadyHasLatestUPassError:
            return "You have the latest UPass."
        case .webViewFailedError:
            return "RenewPass failed to establish a connection. Check your internet connection. UPass and or you school's login might be down."
        case .unknownError:
            return "RenewPass encountered an unknown error."
            
        }
    }
}
