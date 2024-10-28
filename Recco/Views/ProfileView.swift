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
    @StateObject var userListsViewModel = UserListsViewModel()
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
            
            VStack {
                HStack {
                    if let tags = userDataViewModel.currentUser?.tags {
                        ForEach(tags.prefix(2), id: \.id) { tag in
                            TagView(tag: tag)
                        }
                    }
                }
                HStack {
                    if let tags = userDataViewModel.currentUser?.tags, tags.count > 2 {
                        ForEach(tags[2..<min(5, tags.count)], id: \.id) { tag in
                            TagView(tag: tag)
                        }
                    }
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

struct TagView: View {
    let tag: Tag
    var body: some View{
        HStack(spacing: 4){
            FontedText(tag.emoji)
                .font(.system(size: 10))
            FontedText(tag.name)
                .font(.system(size: 10))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .cornerRadius(16)
               .overlay(
                   RoundedRectangle(cornerRadius: 16)
                       .stroke(Color.gray, lineWidth: 1)
               )
            .fixedSize()
    }
}



#Preview {
    ProfileView()
        .environmentObject(UserDataViewModel(user: mockUser))
}

