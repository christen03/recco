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
                    AppView()
                        .environmentObject(userDataViewModel)
                        .environmentObject(authViewModel)
                        .preferredColorScheme(.light)
        }
    }
}
