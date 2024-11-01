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
    @EnvironmentObject var homeNavigation: HomeNavigation
    @StateObject var userListsViewModel = UserListsViewModel()
    @State var isPresentingTagSheet: Bool = false
    
    let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    
    var body: some View{
        NavigationStack(path: $homeNavigation.navigationPath){
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
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(userListsViewModel.userLists) { list in
                            ProfileListItemView(list: list)
                        }
                    }
                    .padding(.horizontal, 16)
                    .animation(.spring(), value: userListsViewModel.userLists)
                }
                .overlay {
                    if userListsViewModel.isFetching {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                    }
                }
            }
            .sheet(isPresented: $isPresentingTagSheet){
                TagSelectionView(userDataViewModel: userDataViewModel,
                                 isPresentingTagSheet: $isPresentingTagSheet)
                .presentationDetents([.medium])
            }
            .navigationDestination(for: List.self) {
                list in EditListView(list: list)
            }
        }
        .environmentObject(homeNavigation)
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

struct ProfileListItemView: View {
    @EnvironmentObject var homeNavigation: HomeNavigation
    let list: List
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(list.emoji ?? "")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TitleText(list.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            FontedText(list.formatItemSummary())
                .foregroundStyle(Colors.MediumGray)
                .font(.system(size: 10))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .onTapGesture {
            homeNavigation.navigateToEditList(list: self.list)
        }
        .padding()
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.scale.combined(with: .opacity))
        .background(Colors.LightGray)
        .cornerRadius(16)
    }
}

extension List{
    func itemSummary(maxItems: Int = 3) -> (displayedItems: [String], leftoverItemCount: Int){
        let allItems: [Item] = sections.flatMap {$0.items} + unsectionedItems
        
        guard !allItems.isEmpty else {
           return ([], 0)
        }
        
        let itemsToShow = Array(allItems.prefix(maxItems))
        let displayItems = itemsToShow.map(\.name)
        
        let remainingCount = allItems.count - itemsToShow.count
        return (displayItems, remainingCount)
    }
    
    func formatItemSummary(maxItems: Int = 3) -> String {
        let summary = itemSummary(maxItems: maxItems)
       
        var resString = ""
        if !summary.displayedItems.isEmpty {
            resString += summary.displayedItems.joined(separator: ", ")
            if summary.leftoverItemCount > 0 {
                resString += ", and \(summary.leftoverItemCount) more"
            }
            return resString
        } else {
            return "No items"
        }
    }
}


#Preview {
    ProfileView()
        .environmentObject(UserDataViewModel(user: mockUser))
}

