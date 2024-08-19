//
//  EnterNameView.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI

struct EnterNameView: View {
    @EnvironmentObject var authNavigation: AuthNavigation
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            TitleText("What's your name?")
                .padding(.bottom, 20)
            
            TextField("First name", text: $supabaseSignUp.firstName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .autocapitalization(.words)
                .disableAutocorrection(true)
            
            TextField("Last Name", text: $supabaseSignUp.lastName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .autocapitalization(.words)
                .disableAutocorrection(true)
            
            NavigationLink(destination: EnterUsernameView()) {
                FontedText("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!supabaseSignUp.areNamesValid ? Color(.systemGray4) : Color.black)
                    .cornerRadius(10)
            }
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .disabled(!supabaseSignUp.areNamesValid)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    EnterNameView()
}
