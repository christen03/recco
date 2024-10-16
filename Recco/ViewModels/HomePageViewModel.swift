//
//  HomePageViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/24/24.
//

import Foundation

class HomePageViewModel: ObservableObject {
    
    @Published var isShowingCreateButtonOptions: Bool = true
    @Published var isShowingCreateListSheet: Bool = false
    @Published var isShowingListCreateSheet: Bool = false
    
}
