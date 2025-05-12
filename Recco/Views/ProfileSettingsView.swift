//
//  ProfileSettingsView.swift
//  Recco
//
//  Created by Christen Xie on 11/2/24.
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    var body: some View {
        SwiftUI.List {
            BodyText("Account")
            BodyText("Edit Profile")
            BodyText("Sign out of Recco")
                .onTapGesture {
                    Task {
                        userDataViewModel.signOut()
                    }
                }
        }
    }
}
#Preview {
    ProfileSettingsView()
}
