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
    @State var isPresentingTagSheet: Bool = false
    
    var body: some View{
        VStack{
            FontedText(userDataViewModel.currentUser?.firstName ?? "" + (userDataViewModel.currentUser?.lastName ?? ""))
            FontedText("@\(userDataViewModel.currentUser?.username ?? "")")
            KFImage(userDataViewModel.currentUser?.profilePictureUrl ?? Constants.DEFAULT_PROFILE_PICTURE_URL)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 150, height: 150)
            
                HStack {
                    ForEach(Array(userDataViewModel.currentUser?.tags.prefix(2) ?? []), id: \.self) { tag in
                        Text(tag.name)
                    }
                }
            Button(action: {
                isPresentingTagSheet.toggle()
            }, label: {
                Text("Show sheet")
            })
            Button(action: {
                userDataViewModel.signOut()
            }, label: {
                Text("Sign out")
            })
        }
        .sheet(isPresented: $isPresentingTagSheet){
            TagSelectionView(userDataViewModel: userDataViewModel)
                .presentationDetents([.medium])
        }
    }
}



#Preview {
    ProfileView()
        .environmentObject(UserDataViewModel(user: mockUser))
}

