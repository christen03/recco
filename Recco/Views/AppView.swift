//
//  AppView.swift
//  Recco
//
//  Created by chris10 on 4/21/25.
//

import SwiftUI

struct AppView: View {
    
    enum AppState {
        case signedOut
        case newUser
        case returningUser
    }
    
    @EnvironmentObject private var userDataViewModel: UserDataViewModel
    @State private var appState: AppState = .signedOut
    
    var body: some View {
        Group {
            switch appState {
            case .signedOut:
                SplashScreenView()
            case .newUser:
                EnterNameView()
            case .returningUser:
                ContentView()
                
            }
            
        }
        .task {
            for await state in supabase.auth.authStateChanges {
                if state.event == .signedOut {
                    appState = .signedOut
                    userDataViewModel.currentUser = nil
                } else if [.initialSession, .signedIn].contains(state.event){
                    if state.session != nil {
                        await userDataViewModel.fetchUserDataFromSupabase()
                        if userDataViewModel.isUserAuthenticated {
                            appState = userDataViewModel.currentUser == nil ? .newUser : .returningUser
                        } else {
                            appState = .signedOut
                        }
                    }
                }
            }
        }
        .onChange(of: userDataViewModel.currentUser) { newValue in
                  if userDataViewModel.isUserAuthenticated {
                      appState = newValue == nil ? .newUser : .returningUser
            }
        }
    }
    
}

