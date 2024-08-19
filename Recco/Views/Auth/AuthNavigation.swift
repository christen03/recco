//
//  AuthNavigation.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI

class AuthNavigation: ObservableObject{
    @Published var navigationPath = NavigationPath()
    
    func navigateToSignUpOrLoginPage(option: SignUpOrLoginOptions){
        self.navigationPath.append(option)
    }
    
    func navigateToSignUpPage(option: SignUpOptions){
        self.navigationPath.append(option)
    }
    
    func navigateToVerificationCodePage(){
        self.navigationPath.append(1)
    }
    
    func navigateToNamePage(){
        self.navigationPath.append("ab")
    }
    
    func navigateToProfilePicturePage(){
        self.navigationPath.append(Character("A"))
    }
}
