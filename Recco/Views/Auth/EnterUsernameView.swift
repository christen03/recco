//
//  EnterUsernameView.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI

struct EnterUsernameView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var authNavigation: AuthNavigation
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel

    var body: some View {
        VStack {
            Spacer()
            
            TitleText("Choose a username")
                .padding(.bottom, 20)
            
            TextField("@username", text: $supabaseSignUp.username)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button(action: {
                Task{
                    if let user = await supabaseSignUp.verifyUsernameIsUniqueAndCreateUser() {
                        userDataViewModel.currentUser=user
                        authNavigation.navigateToProfilePicturePage()
                    }
                }
            }, label: {
                FontedText(supabaseSignUp.isLoading ? "Loading..." : "Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!supabaseSignUp.areNamesValid || supabaseSignUp.isLoading ? Color(.systemGray4) : Color.black)
                    .cornerRadius(10)
            })
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .disabled(!supabaseSignUp.areNamesValid || supabaseSignUp.isLoading)
            Spacer()
        }
        .toastView(toast: $supabaseSignUp.toast)
        .padding()
    }
}

#Preview {
    EnterUsernameView()
}
