//
//  Kingfisher.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import SwiftUI
import Kingfisher

struct KingfisherImage: View {
    
    let imageUrl: URL
    
    var body: some View {
        KFImage(imageUrl)
            .resizable()
    }
}
