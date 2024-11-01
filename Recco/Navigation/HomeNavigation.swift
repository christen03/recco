//
//  HomeNavigation.swift
//  Recco
//
//  Created by Christen Xie on 8/26/24.
//

import SwiftUI

class HomeNavigation: ObservableObject{
    @Published var navigationPath = NavigationPath()
    
    func navigateToEditList(list: List){
        navigationPath.append(list)
    }
    
    func back(){
        navigationPath.removeLast()
    }
}

