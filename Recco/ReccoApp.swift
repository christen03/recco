//
//  ReccoApp.swift
//  Recco
//
//  Created by Christen Xie on 8/3/24.
//

import SwiftUI
import Supabase

@main
struct ReccoApp: App {
    
    @StateObject var userDataViewModel = UserDataViewModel()
//    @StateObject var userDataViewModel = UserDataViewModel(user: mockUser)
    @StateObject var authViewModel = SupabaseAuthViewModel()
    
    var body: some Scene {
        WindowGroup {
//            if(userDataViewModel.isUserAuthenticated){
//                ContentView()
//                .environmentObject(authViewModel)
//                .environmentObject(userDataViewModel)
//
//            } else {
//                SplashScreenView()
//                    .environmentObject(authViewModel)
//                    .environmentObject(userDataViewModel)
//            }
            EditListView()
                .environmentObject(mockListVM)
        }
    }
}
