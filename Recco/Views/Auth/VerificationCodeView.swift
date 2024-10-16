//
//  VerificationCodeView.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI

struct VerificationCodeView: View {
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    @EnvironmentObject var authNavigation: AuthNavigation
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State var isCodeValid: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            TitleText("Enter the code we sent to \(supabaseSignUp.authMethod == .email ? supabaseSignUp.email : supabaseSignUp.phone)")
                .padding(.bottom, 20)
            
            TextField("Enter code", text: $supabaseSignUp.code)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .onChange(of: supabaseSignUp.code, perform: { newCode in
                    self.isCodeValid = self.validateCode(newCode)
                })
            Button(action: {
                Task{
                    let success = await supabaseSignUp.verifyCodeButtonTapped()
                    if(success){
                        if(supabaseSignUp.isSigningUp){
                            authNavigation.navigateToNamePage()
                        } else {
                            userDataViewModel.login()
                        }
                    }
                }
            }, label: {
                FontedText(supabaseSignUp.isLoading ? "Loading..." : "Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!self.isCodeValid || supabaseSignUp.isLoading ? Color(.systemGray4) : Color.black)
                    .cornerRadius(10)
            })
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .disabled(!self.isCodeValid || supabaseSignUp.isLoading)
            
            Spacer()
        }
        .toastView(toast: $supabaseSignUp.toast)
        .padding()
    }
    
    private func validateCode(_ code: String) -> Bool {
        return code.count==6 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: code))
    }
    
}


//#Preview {
//    VerificationCodeView(signUpOption: .phone)
//}
