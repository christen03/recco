//
//  AppView.swift
//  Recco
//
//  Created by chris10 on 4/21/25.
//

import SwiftUI

struct AppView: View {
  @State var isAuthenticated = false

  var body: some View {
    Group {
      if isAuthenticated {
          ContentView()
      } else {
        SplashScreenView()
      }
    }
    .task {
      for await state in supabase.auth.authStateChanges {
        if [.initialSession, .signedIn, .signedOut].contains(state.event) {
          isAuthenticated = state.session != nil
        }
      }
    }
  }
}

