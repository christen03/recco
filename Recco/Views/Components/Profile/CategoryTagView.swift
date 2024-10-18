//
//  CategoryTag.swift
//  Recco
//
//  Created by Christen Xie [I] on 10/17/24.
//

import SwiftUI



struct CategoryTagView: View{
    let data: CategoryTag
    
    var body: some View {
        FontedText("\(data.emoji) \(data.name)")
            .padding()
            .cornerRadius(10)
    }
    
}
