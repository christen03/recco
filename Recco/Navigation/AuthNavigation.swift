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
    
    func navigateToAuthPage(option: AuthOptions){
        self.navigationPath.append(option)
    }
    
    func navigateToVerificationCodePage(){
        self.navigationPath.append(1)
    }
    
}
