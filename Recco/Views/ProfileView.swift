//
//  ProfileView.swift
//  Recco
//
//  Created by Christen Xie on 8/3/24.
//

import SwiftUI
import Kingfisher

struct ProfileView: View{
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    
    var body: some View{
        VStack(spacing: 5){
            TitleText("\(userDataViewModel.currentUser?.firstName ?? "") \(userDataViewModel.currentUser?.lastName ?? "")")
            
            FontedText("@\(userDataViewModel.currentUser?.username ?? "")")
            
            KFImage(Constants.DEFAULT_PROFILE_PICTURE_URL)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .shadow(radius: 10)
                .frame(width: 100, height: 100)
            
            Button(action: {
                userDataViewModel.signOut()
            }, label: {
                Text("Sign out")
            })}
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserDataViewModel(user: mockUser))
}
