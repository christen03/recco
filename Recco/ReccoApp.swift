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
    @StateObject var authViewModel = SupabaseAuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if(userDataViewModel.isUserAuthenticated){
                
                ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userDataViewModel)
                .preferredColorScheme(.light)

            } else {
                SplashScreenView()
                    .environmentObject(authViewModel)
                    .environmentObject(userDataViewModel)
                    .preferredColorScheme(.light)
            }
        }
    }
}
