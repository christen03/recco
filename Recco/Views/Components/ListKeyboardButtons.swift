//
//  ListKeyboardButtons.swift
//  Recco
//
//  Created by Christen Xie on 9/15/24.
//

import SwiftUI

struct ListKeyboardButtons: View {
    
    @State var isShowingPriceOptions: Bool = false
    @EnvironmentObject var listViewModel: ListViewModel
    var currentIndex: ListFocusIndex
    
    var body: some View{
            if(self.isShowingPriceOptions){
                HStack(spacing: 1){
                    KeyboardButton(action: {self.isShowingPriceOptions=false}) {
                        Image(systemName: "xmark")
                    }
                    KeyboardButton(action: {
                        if let index = self.currentIndex{
                            listViewModel.setPriceRange(
                                atSection: index.section,
                                atIndex: index.index,
                                to: .free)
                        }
                    }) {
                        Text("Free")
                            .font(.custom(Fonts.sfProRoundedBold, size: 22))
                    }
                    KeyboardButton(action: {
                        if let index = self.currentIndex{
                            listViewModel.setPriceRange(
                                atSection: index.section,
                                atIndex: index.index,
                                to: .one)
                        }
                    }) {
                        Image(systemName: "dollarsign")
                    }
                    KeyboardButton(action: {
                        if let index = self.currentIndex{
                            listViewModel.setPriceRange(
                                atSection: index.section,
                                atIndex: index.index,
                                to: .two
                            )
                        }
                    }) {
                        HStack(spacing: -2){
                            Image(systemName: "dollarsign")
                            Image(systemName: "dollarsign")
                        }
                    }
                    KeyboardButton(action: {
                        if let index = self.currentIndex {
                            listViewModel.setPriceRange(
                                atSection: index.section,
                                atIndex: index.index,
                                to: .three
                            )
                        }
                    }) {
                        HStack(spacing: -2){
                            Image(systemName: "dollarsign")
                            Image(systemName: "dollarsign")
                            Image(systemName: "dollarsign")
                        }
                    }
                    Spacer()
                }
                // FIXME: animations
                .animation(.easeInOut, value: isShowingPriceOptions)
                .transition(.move(edge:.leading))
            } else {
                HStack(spacing: 1){
                    KeyboardButton(action: { /* Create new section */ }) {
                        Image(systemName: "list.bullet.indent")
                    }
                    
                    KeyboardButton(action: { self.isShowingPriceOptions = true }) {
                        Image(systemName: "dollarsign")
                    }
                    
                    KeyboardButton(action: {
                        print("Pressed button for \(self.currentIndex)")
                        if let index = self.currentIndex {
                            listViewModel.toggleFavoriteForIndex(
                                atSection: index.section,
                                atIndex: index.index
                            )
                        }
                    }) {
                        Text("⭐️")
                            .font(.title2)
                    }
                    Spacer()
                }
                .animation(.easeInOut, value: isShowingPriceOptions)
                .transition(.move(edge: .leading))
            }
        }
    }
    struct KeyboardButton<Content: View>: View {
        let action: () -> Void
        let content: Content
        
        init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
            self.action = action
            self.content = content()
        }
        
        var body: some View {
            Button(action: action) {
                content
                    .frame(height: 30)
                    .padding(.horizontal, 5)
                    .background(Colors.BorderGray)
                    .cornerRadius(10)
                    .foregroundStyle(Color.black)
            }
    }
}
