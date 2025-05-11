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
        print("sections: \(list.sections)")
        print("unsectionedItems \(list.unsectionedItems)")
        navigationPath.append(list)
    }
    
    func navigateToSettings(){
        navigationPath.append(1)
    }
    
    func back(){
        navigationPath.removeLast()
    }
}

