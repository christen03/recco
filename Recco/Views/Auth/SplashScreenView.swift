//
//  SplashScreen.swift
//  Recco
//
//  Created by Christen Xie on 8/12/24.
//

import SwiftUI

enum AuthOptions: Hashable{
    case phone
    case email
}

enum SignUpOrLoginOptions: Hashable {
    case login
    case signup
}

struct SplashScreenView: View {
    
    @EnvironmentObject var supabaseSignUp : SupabaseAuthViewModel
    @StateObject var authNavigation = AuthNavigation()
    
    var body: some View {
        NavigationStack(path: $authNavigation.navigationPath){
            ZStack{
                ReccoBackgroundText()
                VStack {
                    Spacer()
                    NavigationLink(destination: SignUpOrLoginView()){
                        FontedText("Get Started")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(25)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .navigationDestination(for: AuthOptions.self) {
                option in AuthView(authOption: option)
            }
            .navigationDestination(for: Int.self) { _ in
                VerificationCodeView()
            }
        }
        .environmentObject(authNavigation)
    }
}


struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}


#Preview {
    SplashScreenView()
}
