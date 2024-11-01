//
//  HomePageViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/24/24.
//

import Foundation

class HomePageViewModel: ObservableObject {
    
    
    var isListCreated: Bool = false
    @Published var isShowingCreateButtonOptions: Bool = false
    @Published var isShowingListCreateSheet: Bool = false
    @Published var isShowingCreateListSheet: Bool = false
    @Published var isShowingEmojiPicker: Bool = false
    @Published var isShowingVisibilitySheet: Bool = false
    
    @Published var canCreateList: Bool = false
    @Published var list: List {
        didSet {
            validateListFields()
        }
    }
    
    init(){
        self.list=List.empty()
    }
    
    
    func createList(userId: UUID){
        guard !isListCreated else { return }
        self.list = List(name: "",
                                creatorId: userId,
                                emoji: nil,
                                visibility: ListVisibility.global)
        self.isListCreated = true
    }
    
    func validateListFields(){
        self.canCreateList = (list.emoji != nil && !list.name.isEmpty)
    }
}
