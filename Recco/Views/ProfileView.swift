//
//  ProfileView.swift
//  Recco
//
//  Created by Christen Xie on 8/3/24.
//

import SwiftUI

struct ProfileView: View{
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    
    var body: some View{
        VStack{
            Text("Profile")
            Button(action: {
                userDataViewModel.signOut()
            }, label: {
                Text("Sign out")
            })
        }
        }
}

