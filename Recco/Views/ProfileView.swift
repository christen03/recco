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
            VStack{
                HStack {
                  Spacer()
                  VStack {
                    TitleText(
                      (userDataViewModel.currentUser?.firstName ?? "") + " "
                      + (userDataViewModel.currentUser?.lastName  ?? "")
                    )
                    FontedText("@\(userDataViewModel.currentUser?.username ?? "")")
                  }
                  Spacer()
                }
                .padding(.horizontal)
                .overlay(
                  Button {
                    homeNavigation.navigateToSettings()
                  } label: {
                    Image(systemName: "gearshape.fill")
                      .foregroundStyle(.black)
                  }
                  .padding(.horizontal),
                  alignment: .trailing
                )
                .padding(.horizontal)
                KFImage(userDataViewModel.currentUser?.profilePictureUrl ?? Constants.DEFAULT_PROFILE_PICTURE_URL)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
                    Spacer()
                
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
                    ScrollView {
                        if userListsViewModel.userLists.isEmpty {
                            TitleText("Try creating a new list!")
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(userListsViewModel.userLists) { list in
                                    ProfileListItemView(list: list)
                                }
                            }
                            .padding(.horizontal, 16)
                            .animation(.spring(), value: userListsViewModel.userLists)
                        }
                    }
                    .refreshable {
                        await userListsViewModel.fetchUsersLists()
                    }
                    .overlay {
                        if userListsViewModel.isFetching {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                        }
                }
            .sheet(isPresented: $isPresentingTagSheet){
                TagSelectionView(userDataViewModel: userDataViewModel,
                                 isPresentingTagSheet: $isPresentingTagSheet)
                .presentationDetents([.medium])
            }
            .task {
                await userListsViewModel.fetchUsersLists()
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
// MARK: - ProfileListItemView
struct ProfileListItemView: View {
    @EnvironmentObject var homeNavigation: HomeNavigation
    let list: List
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(list.emoji ?? "")
                .font(.system(size: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(list.name)
                .font(Font.custom(Fonts.sfProDisplaySemibold, size: 24))
                .foregroundStyle(Colors.ListTitleGray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Show items summary that fits in 2 lines with ellipses
            BodyText(list.formatItemSummary())
                .foregroundStyle(Colors.MediumGray)
                .font(.system(size: 10))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .truncationMode(.tail)
            
            Spacer()
            
            // Total item count in bottom left
            Text("\(list.totalItemCount) item\(list.totalItemCount == 1 ? "" : "s")")
                .foregroundStyle(Colors.MediumGray)
                .font(.system(size: 10))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.scale.combined(with: .opacity))
        .background(Colors.SuperLightGray)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Colors.LightGray, lineWidth: 1)
        )
        .onTapGesture {
            homeNavigation.navigateToEditList(list: self.list)
        }
    }
}

// MARK: - List Extension
extension List {
    var totalItemCount: Int {
        let allItems: [Item] = sections.flatMap {$0.items} + unsectionedItems
        return allItems.count
    }
    
    func itemSummary(maxItems: Int = 10) -> (displayedItems: [String], hasMore: Bool) {
        let allItems: [Item] = sections.flatMap {$0.items} + unsectionedItems
        
        guard !allItems.isEmpty else {
           return ([], false)
        }
        
        let itemsToShow = Array(allItems.prefix(maxItems))
        let displayItems = itemsToShow.map(\.name)
        
        let hasMore = allItems.count > itemsToShow.count
        return (displayItems, hasMore)
    }
    
    func formatItemSummary(maxItems: Int = 10) -> String {
        let summary = itemSummary(maxItems: maxItems)
       
        if !summary.displayedItems.isEmpty {
            var resString = summary.displayedItems.joined(separator: " • ")
            if summary.hasMore {
                resString += "..."
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

