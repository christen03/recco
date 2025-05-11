//
//  ProfileSettingsView.swift
//  Recco
//
//  Created by Christen Xie on 11/2/24.
//

import SwiftUI

struct ProfileSettingsView: View {
    var body: some View {
        SwiftUI.List{
           BodyText("Account")
            BodyText("Edit Profile")
            BodyText("Sign out of Recco")
        }
    }
    
}

#Preview {
    ProfileSettingsView()
}
