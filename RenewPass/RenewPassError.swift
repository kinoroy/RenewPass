//
//  RenewPassError.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-07.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

import Foundation

/// An enum representing all of the possible errors that can be thrown in the program
enum RenewPassError: Error {
    
    case authenticationFailedError
    case schoolNotFoundError
    case alreadyHasLatestUPassError
    case webViewFailedError
    case verificationFailed
    case unknownError
    
}

/// An extension providing 
extension RenewPassError: CustomStringConvertible {
    /// A title for the error which will be displayed in the status label on the renew screen
    var title: String {
        switch self {
            
        case .authenticationFailedError:
            return "Authentication failed"
        case .schoolNotFoundError:
            return "School not supported"
        case.alreadyHasLatestUPassError:
            return "You already have the latest UPass"
        case .webViewFailedError:
            return "Failed to establish a connection"
        case .verificationFailed:
            return "Couldn't verify the renew, check UPassBC"
        case .unknownError:
            return "Unknown error."
            
        }
    }
    /// An extended description of the error. Not currently displayed to the user anywhere in the app.
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
        case .verificationFailed:
            return "RenewPass couldn't verify that the renew was completed successfully. Check the UPassBC site to verify."
        case .unknownError:
            return "RenewPass encountered an unknown error."
            
        }
    }
}
