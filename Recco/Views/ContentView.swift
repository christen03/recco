//
//  ContentView.swift
//  Recco
//
//  Created by Christen Xie on 8/3/24.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    
    @StateObject var homeNavigation = HomeNavigation()
    #if DEBUG
    @StateObject var listViewModel = mockListVM
    #else
    @StateObject var listViewModel = ListViewModel()
    #endif
    @StateObject var homePageViewModel = HomePageViewModel()
    @State private var selectedTab = 0
    @State private var profileTab: Image?
    
    var body: some View {
        NavigationStack(path: $homeNavigation.navigationPath){
            GeometryReader { geometry in
                ZStack {
                    // Main TabView
                    TabView(selection: $selectedTab) {
                        FeedView()
                            .tabItem {
                                Image(systemName: "house")
                                    .imageScale(.large)
                            }
                            .tag(0)
                        
                        ProfileView()
                            .tabItem {
                            }
                            .tag(1)
                    }
                    
                    //TODO: Implement versioning strategy to show updated photo
                    //FIXME: Doesn't display uploaded pfp on first render
                    Button(action: {
                        self.selectedTab = 1
                    }) {
                        //                    KFImage(userDataViewModel.currentUser?.profilePictureUrl ?? Constants.DEFAULT_PROFILE_PICTURE_URL)
                        KFImage(Constants.DEFAULT_PROFILE_PICTURE_URL)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .frame(width: 35, height: 35)
                    }
                    .position(x: geometry.size.width / 4 * 3, y: geometry.size.height - 30)
                    
                    CreateButton(action: {
                        withAnimation(.spring()){
                            homePageViewModel.isShowingCreateButtonOptions.toggle()
                        }
                    }, showMenu: $homePageViewModel.isShowingCreateListSheet)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 40)
                }
            }
            .navigationDestination(for: Int.self) { _ in EditListView()}
        }
        .environmentObject(homePageViewModel)
       .environmentObject(homeNavigation)
       .environmentObject(listViewModel)
        .sheet(isPresented: $homePageViewModel.isShowingListCreateSheet, onDismiss: {
            print("Dismissed sheet")
        }, content: {
            PresentationSheetView()
                .environmentObject(homeNavigation)
                .environmentObject(homePageViewModel)
                .environmentObject(listViewModel)
                .presentationDetents([PresentationDetent.fraction(0.75)])
        })
    }
}


struct PresentationSheetView: View {
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    @EnvironmentObject var homeNavigation: HomeNavigation
    @EnvironmentObject var listViewModel: ListViewModel

    var body: some View{
        VStack{
            HStack{
                Button(action: {
                    print("Close button tapped")
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.black)
                        .padding(.trailing, 30)
                        .frame(width: 60, alignment: .leading)
                })
                Spacer()
                FontedText("New list", size: 16)
                Spacer()
                Button(action: {
                    homePageViewModel.isShowingListCreateSheet = false
                    homeNavigation.navigateToEditList()
                }, label: {
                    FontedText("Create", size: 14)
                        .frame(width: 60)
                        .foregroundColor(listViewModel.canCreateList ? Color.black : Colors.DisabledGray)
                })
                .disabled(!listViewModel.canCreateList)
                .environmentObject(listViewModel)
            }
            Button(action: {
                listViewModel.isShowingEmojiPicker = true
            }, label: {
                // I used a package for this, but its a little outdated so it's only up to iOS 16 emojis 
                if let emoji = self.listViewModel.list.emoji{
                    Text(emoji)
                        .font(.system(size: 50))
                } else {
                    AddIcon(size: 50)
                }
            })
            .padding(.vertical, 20)
            HStack {
                TextField("", text: $listViewModel.list.name,
                          prompt: Text("List name")
                    .foregroundColor(Colors.DarkGray)
                    .font(Font.custom(Fonts.sfProRounded, size: 25))
                
                )
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 208)
                    .foregroundStyle(Colors.DarkGray)
                    .font(Font.custom(Fonts.sfProRounded, size: 25 ))
                    .multilineTextAlignment(.center)
            }
            HStack{
                FontedText("Visibility", size: 16)
                    .foregroundColor(Colors.MediumGray)
                Spacer()
            }
            HStack(spacing: 10){
                ForEach(ListVisibility.allCases, id: \.self){ visibility in
                    Button(action: {
                        self.listViewModel.list.visibility = visibility
                    }) {
                        FontedText(visibility.rawValue, size: 16)
                            .lineLimit(1)
                            .fixedSize()
                            .padding(.vertical, 3)
                            .padding(.horizontal, 10)
                            .background(self.listViewModel.list.visibility == visibility ? Color.black : nil)
                            .foregroundColor(self.listViewModel.list.visibility == visibility ? Color.white : Color.black)
                            .cornerRadius(15.0)
                            .font(.system(size: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Colors.BorderGray)
                            )
                    }
                }
                Spacer()
            }
            .padding(.top, 3)
            .padding(.bottom, 7)
            
            HStack{
                FontedText("Select friends", size: 16)
                    .foregroundColor(Colors.MediumLightGray)
                Spacer()
            }
            
            HStack{
                Button(action: {
                    print("Add friends icon tapped")
                }, label: {
                    AddIcon(size: 36)
                })
                Spacer()
            }
            Spacer()
            
        }
        .sheet(isPresented: $listViewModel.isShowingEmojiPicker, content: {
            ElegantEmojiPickerView(selectedEmoji: $listViewModel.list.emoji)
        })
        .padding(.vertical)
        .padding(.horizontal, 40)
    }
}

struct AddIcon: View {
    let size: CGFloat
    
    var body: some View{
        ZStack{
            Circle()
                .fill(Colors.LightGray)
                .frame(width: size, height: size)
            Text("+")
                .font(Font.custom(Fonts.sfProRoundedSemibold, size: size*2/3))
                .foregroundColor(Colors.MediumGray)
                .baselineOffset(3)
        }
    }
}


struct CreateButton: View {
    let action: () -> Void
    @Binding var showMenu: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                showMenu.toggle()
            }
        }) {
            Image(systemName: "plus")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.black)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .overlay(
            Group {
                if showMenu {
                    CreateButtonOptions()
                        .offset(y: -100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
    }
}

struct CreateButtonOptions: View {
    
    var body: some View {
        VStack {
            Button(action: {
                print("Create new list tapped")
            }) {
                HStack{
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    FontedText("Create new List")
                }
                .background(Color.red)
            }
            .padding()
            .background(Color.white)
            .foregroundColor(Color.black)
            Button(action: {
                print("Ask for recs tapped")
            }) {
                HStack{
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    FontedText("Ask for recs")
                }
            }
            .padding()
            .background(Color.white)
            .foregroundColor(Color.black)
        }
        .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    ContentView()
        .environmentObject(UserDataViewModel(user: mockUser))
}

