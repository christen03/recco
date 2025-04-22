//
//  AuthError.swift
//  Recco
//
//  Created by Christen Xie [I] on 10/17/24.
//
import SwiftUI

enum AuthError: LocalizedError {
    case userAlreadyExists(message: String)
    case noUserLoggedIn
    
    
    var errorDescription: String? {
        switch self {
        case .userAlreadyExists(let message):
            return message
        case .noUserLoggedIn:
            return "Error getting current user data"
        }
    }
     
    var recoverySuggestion: String? {
        switch self {
        case .userAlreadyExists:
            return "Please try logging in instead"
            
        case .noUserLoggedIn:
            return "Pleaes try logging in again"
        }
    }
}
