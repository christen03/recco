//
//  SignUp.swift
//  Recco
//
//  Created by Christen Xie on 8/12/24.
//

import SwiftUI

struct SignUpView: View {
    
    let signUpOption: SignUpOptions
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    @EnvironmentObject var authNavigation: AuthNavigation
    
    var body: some View {
        VStack{
            if(signUpOption == .email){
                EmailSignUpView()
            } else {
                PhoneSignUpView()
            }
        }
        .toastView(toast: $supabaseSignUp.toast)
        // We start prefetching the default profile picture image here so it's loaded when we get to the image upload screen
        .onAppear {
            ImagePrefetcher.fetcher.startPrefetchingForKey(key: PrefetcherKeys.defaultProfile)
        }
    }
    
    struct EmailSignUpView: View {
        @EnvironmentObject var authNavigation: AuthNavigation
        @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
        
        var body: some View {
            VStack {
                Spacer()
                
                TitleText("What’s your email?")
                    .padding(.bottom, 20)
                
                TextField("name@mail.com", text: $supabaseSignUp.email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
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
                        .background(!supabaseSignUp.isEmailValid || supabaseSignUp.isLoading ? Color(.systemGray4) : Color.black)
                        .cornerRadius(10)
                })
                .padding(.top, 30)
                .padding(.horizontal, 20)
                .disabled(!supabaseSignUp.isEmailValid || supabaseSignUp.isLoading)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct PhoneSignUpView: View {
    @EnvironmentObject var authNavigation: AuthNavigation
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            TitleText("What's your phone number?")
                .padding(.bottom, 20)
            
            TextField("Enter phone number", text: $supabaseSignUp.phone)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .keyboardType(.phonePad)
            
            Button(action: {
                Task {
                    let success = await supabaseSignUp.signUpButtonTapped()
                    if(success){
                        authNavigation.navigateToVerificationCodePage()
                    }
                }
            }) {
                FontedText(supabaseSignUp.isLoading ? "Loading..." : "Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!supabaseSignUp.isPhoneValid || supabaseSignUp.isLoading ? Color(.systemGray4) : Color.black)
                    .cornerRadius(10)
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .disabled(!supabaseSignUp.isPhoneValid || supabaseSignUp.isLoading)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SignUpView(signUpOption: .phone)
}
