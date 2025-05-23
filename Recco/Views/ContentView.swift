//
//  ContentView.swift
//  Recco
//
//  Created by Christen Xie on 8/3/24.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @StateObject var homeNavigation = HomeNavigation()
    @StateObject var homePageViewModel = HomePageViewModel()
    @State private var selectedTab = 0
    @State private var profileTab: Image?
    @State private var authenticationError: Bool = false
    
    var listViewModel: ListViewModel? = nil
    
    var body: some View {
//        if authenticationError{
//            VStack{
//                TitleText("Sorry! We had an error fetching your session. Please try signing out and signing back in.")
//                Button(action: {
//                    userDataViewModel.signOut()
//                },label: {
//                    FontedText("Sign Out")
//                })
//            }
//        }
        
        NavigationStack(path: $homeNavigation.navigationPath){
            GeometryReader { geometry in
                ZStack {
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
                    
                    Button(action: {
                        self.selectedTab = 1
                    }) {
                        KFImage(userDataViewModel.currentUser?.profilePictureUrl ?? Constants.DEFAULT_PROFILE_PICTURE_URL)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .frame(width: 45, height: 45)
                    }
                    .position(x: geometry.size.width / 4 * 3, y: geometry.size.height - 30)
                    
                    CreateButton()
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 40)
                }
            }
            .navigationDestination(for: List.self) { list in  ListEditView(list: list )}
            .navigationDestination(for: Int.self) { _ in ProfileSettingsView()} 
        }
        .task{
           await homePageViewModel.createList()
        }
        .overlay(
            ZStack(alignment: .bottom) {
                if homePageViewModel.isShowingCreateButtonOptions {
                    GeometryReader { geometry in
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    homePageViewModel.isShowingCreateButtonOptions = false
                                }
                            }
                    }
                    CreateButtonOptions()
                        .offset(y: -70)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
        .sheet(isPresented: $homePageViewModel.isShowingListCreateSheet,  content: {
            PresentationSheetView()
                .presentationDetents([PresentationDetent.fraction(0.75)])
        })
        .environmentObject(homePageViewModel)
        .environmentObject(homeNavigation)
    }
}


struct PresentationSheetView: View {
    
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    @EnvironmentObject var homeNavigation: HomeNavigation
    
    var body: some View{
        VStack{
            HStack{
                Button(action: {
                    homePageViewModel.isShowingListCreateSheet.toggle()
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
                    Task {
                            let newListId = await homePageViewModel.createListInSupabase()
                            DispatchQueue.main.async {
                            homePageViewModel.isShowingListCreateSheet = false
                                let newList = homePageViewModel.list
                                homeNavigation.navigateToEditList(list: newList)
                            }
                            await homePageViewModel.createList()
                    }
                }, label: {
                    FontedText("Create", size: 14)
                        .frame(width: 60)
                        .foregroundColor(homePageViewModel.canCreateList ? Color.black : Colors.DisabledGray)
                })
                .disabled(!homePageViewModel.canCreateList || homePageViewModel.isUploadingListToSupabase)
                .environmentObject(homePageViewModel)
            }
            Button(action: {
                homePageViewModel.isShowingEmojiPicker = true
            }, label: {
                // I used a package for this, but its a little outdated so it's only up to iOS 16 emojis
                if let emoji = self.homePageViewModel.list.emoji{
                    Text(emoji)
                        .font(.system(size: 50))
                } else {
                    AddIcon(size: 50)
                }
            })
            .padding(.vertical, 20)
            HStack {
                TextField("", text: $homePageViewModel.list.name,
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
                        self.homePageViewModel.list.visibility = visibility
                    }) {
                        HStack{
                            FontedText(visibility.emoji, size: 16)
                            FontedText(visibility.rawValue, size: 16)
                        }
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.vertical, 3)
                        .padding(.horizontal, 10)
                        .background(self.homePageViewModel.list.visibility == visibility ? Color.black : nil)
                        .foregroundColor(self.homePageViewModel.list.visibility == visibility ? Color.white : Color.black)
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
      
        .onAppear{
            homePageViewModel.validateListFields()
        }
        .sheet(isPresented: $homePageViewModel.isShowingEmojiPicker, content: {
            ElegantEmojiPickerView(selectedEmoji: $homePageViewModel.list.emoji)
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
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                homePageViewModel.isShowingCreateButtonOptions.toggle()
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
    }
}

struct CreateButtonOptions: View {
    @EnvironmentObject var homePageViewModel: HomePageViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                homePageViewModel.isShowingListCreateSheet.toggle()
                homePageViewModel.isShowingCreateButtonOptions.toggle()
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    
                    Text("Create new list")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding()
            }
            
            Button(action: {
                print("Ask for recs tapped")
            }) {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8) // Add padding to give it a consistent size
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                    
                    Text("Ask for recs")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .padding()
            }
        }
        .background(Colors.LightGray)
        .frame(width: 200)
        .cornerRadius(15)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserDataViewModel(user: mockUser))
}

