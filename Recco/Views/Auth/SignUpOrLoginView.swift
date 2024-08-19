//
//  SignUpOrLoginView.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI

struct SignUpOrLoginView: View {
    
    let signUpOrLogin: SignUpOrLoginOptions
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    @EnvironmentObject var authNavigation: AuthNavigation
    
    var body: some View {
        VStack{
            Spacer()
            if(signUpOrLogin == .signup){
                Button(action: {
                    supabaseSignUp.setAuthOption(option: .phone)
                    authNavigation.navigateToSignUpPage(option: .phone)
                }) {
                    FontedText("Continue with Phone")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                }
                Button(action: {
                    supabaseSignUp.setAuthOption(option: .email)
                    authNavigation.navigateToSignUpPage(option: .email)
                }){
                    FontedText("Continue with Email")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                }
            } else {
                Text("Login screen coming")
            }
        }
    }
}

#Preview {
    SignUpOrLoginView(signUpOrLogin: .signup)
}
