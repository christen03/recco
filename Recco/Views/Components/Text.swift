//
//  Text.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI

struct TitleText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View{
        Text(text)
            .font(Font.custom(Fonts.sfProRoundedSemibold, size: 25))
    }
}

struct HeaderText: View {
    let text: String
    
    init(_ text: String){
        self.text=text;
    }
    
    var body: some View {
        Text(text)
            .font(Font.custom(Fonts.sfProDisplaySemibold, size: 25))
    }
}

struct FontedText: View {
    
    let text: String
    let size: CGFloat?
    
    init(_ text: String, size: CGFloat? = nil){
        self.text=text
        self.size=size
    }
    
    var body: some View{
        Text(text)
            .font(Font.custom(Fonts.sfProDisplayMedium, size: size ?? 18 ))
    }
}


struct BodyText: View {
    
    let text: String
    let size: CGFloat?
    
    init(_ text: String, size: CGFloat? = nil){
        self.text=text
        self.size=size
    }
    
    var body: some View {
        Text(text)
            .font(Font.custom(Fonts.sfProDisplayMedium, size: size ?? 14))
    }
}
