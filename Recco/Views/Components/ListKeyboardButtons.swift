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
    @Binding var currentIndex: ListFocusIndex
    
    var body: some View{
            if(self.isShowingPriceOptions){
                HStack(spacing: 10){
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
                            .font(.custom(Fonts.sfProRoundedBold, size: 18))
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
                .padding(.leading)
                // FIXME: animations
                .animation(.easeInOut, value: isShowingPriceOptions)
                .transition(.move(edge:.leading))
            } else {
                HStack(spacing: 10){
                    KeyboardButton(action: {
                        // -1 represents unsectioned items section
                        let atSectionIndex = self.currentIndex?.section ?? -1
                        self.currentIndex = listViewModel.addNewSection(atSectionIndex: atSectionIndex, atItemIndex: self.currentIndex!.index)
                    }) {
                        Image(systemName: "list.bullet.indent")
                    }
                    
                    KeyboardButton(action: { self.isShowingPriceOptions = true }) {
                        Image(systemName: "dollarsign")
                    }
                    
                    KeyboardButton(action: {
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
                .padding(.leading)
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
