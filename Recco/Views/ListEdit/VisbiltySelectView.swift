//
//  VisbiltySelectView.swift
//  Recco
//
//  Created by chris10 on 3/28/25.
//

import SwiftUI

struct VisibilitySelectView: View {
    @ObservedObject var listViewModel: ListViewModel
    @Binding var isShowingVisibiltySheet: Bool
    
    var body: some View{
        VStack{
            ZStack{
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingVisibiltySheet=false
                    }) {
                        FontedText("Done")
                            .foregroundStyle(Color.black)
                    }
                }
                FontedText("Visibility")
            }
            
            VStack (alignment: .leading){
                ForEach(ListVisibility.allCases, id: \.self){ visibility in
                    Button(action:{
                        listViewModel.updateListVisibilty(visibility)
                    }, label: {
                        HStack(alignment: .center){
                            Text(visibility.emoji)
                                .font(.system(size: 50))
                                .frame(width: 50, height: 50, alignment: .center)
                        VStack(alignment: .leading){
                                FontedText(visibility.rawValue)
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                FontedText(visibility.description, size: 14)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                            }
                            .foregroundStyle(Color.black)
                        }
                        .padding(.vertical)
                        .background(self.listViewModel.list.visibility == visibility ? Colors.LightGray : Color.clear)
                        .cornerRadius(10)
                    }
                    )
                }
                TitleText("Friends coming soon! 🎉")
            }
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}
