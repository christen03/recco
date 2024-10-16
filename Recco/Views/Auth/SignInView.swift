//
//  SignInView.swift
//  Recco
//
//  Created by Christen Xie on 9/28/24.
//

import SwiftUI

struct SignInView: View {
    let signInOption: SignInOptions
    @EnvironmentObject var authNavigation: AuthNavigation
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    var body: some View {
        VStack{
            TitleText("Welcome Back!")
            Button(action: {
                Task{
                    let success = await supabaseSignUp.signUpButtonTapped()
                    if(success){
                        authNavigation.navigateToVerificationCodePage()
                    }
                }
            }, label: {
                FontedText(supabaseSignUp.isLoading ? "Loading..." : "Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!supabaseSignUp.isPhoneValid || supabaseSignUp.isLoading ? Color(.systemGray4) : Color.black)
                    .cornerRadius(10)
            })
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .disabled(supabaseSignUp.isLoading)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignInView(signInOption: SignInOptions.phone)
}
