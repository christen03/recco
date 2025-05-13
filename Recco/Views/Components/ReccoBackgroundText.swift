//
//  ReccoBackgroundText.swift
//  Recco
//
//  Created by Christen Xie on 10/17/24.
//
import SwiftUI


struct ReccoBackgroundText: View {
    var body: some View{
        GeometryReader { geometry in
            Text("recco")
                .font(Font.custom(Fonts.sfProRoundedBold, size: 100) .bold())
                .foregroundStyle(Color(red: 209/255, green: 209/255, blue: 209/255))
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .ignoresSafeArea()
    }
}

