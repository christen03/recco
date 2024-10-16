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

enum SignInOptions: Hashable{
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
            VStack {
                Spacer()
                
                Button(action: {
                    supabaseSignUp.setIsSigningUp(true)
                    authNavigation.navigateToSignUpOrLoginPage(
                        option: SignUpOrLoginOptions.signup
                    )
                })
                {
                    FontedText("Get Started")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    supabaseSignUp.setIsSigningUp(false)
                    authNavigation.navigateToSignUpOrLoginPage(
                        option: SignUpOrLoginOptions.login
                    )
                })
                {
                    FontedText("Already have an account? Log in")
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
            }
            .navigationDestination(for: SignUpOrLoginOptions.self){
                option in SignUpOrLoginView(signUpOrLogin: option)
            }
            .navigationDestination(for: AuthOptions.self) {
                option in SignUpView(signUpOption: option)
            }
            .navigationDestination(for: SignInOptions.self){
                option in SignInView(signInOption: option)
            }
            .navigationDestination(for: Int.self) { _ in
                VerificationCodeView()
            }
            .navigationDestination(for: String.self){ _ in
                EnterNameView()
            }
            .navigationDestination(for: Character.self ) { _ in
                ChooseProfilePictureView()
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
