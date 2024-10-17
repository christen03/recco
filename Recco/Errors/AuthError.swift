//
//  AuthError.swift
//  Recco
//
//  Created by Christen Xie [I] on 10/17/24.
//
import SwiftUI

enum AuthError: LocalizedError {
    case userAlreadyExists(message: String)
    
    var errorDescription: String? {
        switch self {
        case .userAlreadyExists(let message):
            return message
        }
    }
}
