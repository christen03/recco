//
//  ContentView.swift
//  Recco
//
//  Created by Christen Xie on 8/3/24.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @EnvironmentObject var userDataViewModel : UserDataViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button(action: {
                    Task {
                        userDataViewModel.signOut()
                    }
                }) {
                    Text("Sign out")
                }
                Rectangle().fill(Color.red)
                    .frame(width: 10, height: 10)
                TabView(selection: $selectedTab) {
                    FeedView()
                        .tabItem {
                            Image(systemName: "house")
                                .imageScale(.large)
                        }
                        .tag(0)
                    
                    ProfileView()
                        .tabItem {
                            Text("Hello")
                        }
                        .tag(1)
                }
            }
            
//            VStack(spacing: 0) {
//                Divider()
//                    .background(Color.gray.opacity(0.3))
//                    .frame(height: 1)
//                
//                Rectangle()
//                    .fill(Color.clear)
//                    .frame(height: 60)
//            }
//            
            CreateButton(action: {
                print("Center Button Tapped")
            })
        }
    }
}

struct CreateButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action){
            Image(systemName: "plus")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.black)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .offset(y: -20)
    }
}

#Preview {
    ContentView()
}
