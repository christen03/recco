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
                    await MainActor.run {
                        userDataViewModel.currentUser = nil
                        userDataViewModel.isUserAuthenticated = false
                        appState = .signedOut
                    }
                } else if [.initialSession, .signedIn].contains(state.event) {
                    if state.session != nil {
                        await userDataViewModel.fetchUserDataFromSupabase()
                        await MainActor.run {
                            updateAppState()
                        }
                    }
                }
            }
        }
        .onChange(of: userDataViewModel.currentUser) { _ in
            if userDataViewModel.isUserAuthenticated {
                updateAppState()
            }
        }
    }
    
    private func updateAppState() {
        if !userDataViewModel.isUserAuthenticated {
            appState = .signedOut
        } else {
            appState = userDataViewModel.currentUser == nil ? .newUser : .returningUser
        }
    }
    
}

