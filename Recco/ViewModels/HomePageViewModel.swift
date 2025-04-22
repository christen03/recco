//
//  HomePageViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/24/24.
//

import Foundation

class HomePageViewModel: ObservableObject {
    
    var isListCreated: Bool = false
    var userId: UUID?
    @Published var isShowingCreateButtonOptions: Bool = false
    @Published var isShowingListCreateSheet: Bool = false
    @Published var isShowingCreateListSheet: Bool = false
    @Published var isShowingEmojiPicker: Bool = false
    @Published var isShowingVisibilitySheet: Bool = false
    @Published var isUploadingListToSupabase: Bool = false
    @Published var toast: Toast? = nil
    
    @Published var canCreateList: Bool = false
    @Published var list: List {
        didSet {
            validateListFields()
        }
    }
    
    init(){
        self.list=List.empty()
    }
    
    
    
    @MainActor
    func createList() async {
        do{
            guard let userId = try await AuthManager.shared.fetchCurrentUserId() else { return }
            self.list = List(id: UUID(),
                             name: "",
                             creatorId: userId,
                             emoji: nil,
                             visibility: ListVisibility.global,
                             sections: [],
                             items: []
            )
        }
        catch{
            print(error, "createList() error")
            toast = Toast(style: .error, message: "Failed to fetch logged in user")
            return
        }
    }
    
    func validateListFields(){
        self.canCreateList = (list.emoji != nil && !list.name.isEmpty)
    }
    
    @MainActor
    func createListInSupabase() async{
        self.isUploadingListToSupabase = true
        defer { isUploadingListToSupabase=false }
        let listCreateModel = CreateListParams(list: self.list)
        print(listCreateModel)
        do {
            let newListId: UUID = try await supabase
                .rpc(SupabaseFunctions.createList.rawValue,
                     params: listCreateModel)
                .execute()
                .value
            
            var updatedList = self.list
            updatedList.id = newListId
            self.list=updatedList
        } catch {
            print(error, "createListInSupabase() error")
            toast = Toast(style: .error, message: "Error creating list")
        }
    }
}
