//
//  CenterHorizontally.swift
//  Recco
//
//  Created by Christen Xie on 9/1/24.
//

import SwiftUI

private struct CenterHorizontallyModifier: ViewModifier {

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            content
            Spacer()
        }
    }
}

extension View {

    func centerHorizontally() -> some View {
        modifier(CenterHorizontallyModifier())
    }
}
