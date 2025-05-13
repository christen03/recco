//
//  OnboardingNavigation.swift
//  Recco
//
//  Created by chris10 on 5/11/25.
//

import SwiftUI

class OnboardingNavigation: ObservableObject {
    
    @Published var navigationPath = NavigationPath()
    
    func navigateToNamePage(){
        self.navigationPath.append("ab")
    }
    
    func navigateToProfilePicturePage(){
        self.navigationPath.append(Character("A"))
    }
}
