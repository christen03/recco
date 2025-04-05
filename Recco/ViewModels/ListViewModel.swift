//
//  self.swift
//  Recco
//
//  Created by Christen Xie on 8/25/24.
//

import Foundation

enum ListVisibility: String, CaseIterable {
    // Named global becuase 'public' is a reserved keyword
    case global = "Public"
    case friends = "All Friends"
    case restricted = "Restricted"
    
    var emoji: String{
        switch self {
        case .global: return "🌐"
        case .friends: return "👥"
        case .restricted: return "🔒"
        }
    }
    
    
    var description: String {
        switch self{
        case .global:
            return "Everyone can see this list on your profile, but it only appears on your friends’ feeds."
            
        case .friends:
            return "All friends can see this list on your profile and their feeds."
            
        case .restricted:
            return "Only select friends can see this list on your profile and their feeds."
        }
    }
}

enum PriceRange{
    case free
    case one
    case two
    case three
}

class ListViewModel: ObservableObject {
    
    private var userDataViewModel: UserDataViewModel? = nil
    @Published var list: List
    
    
    struct UIState {
        var isShowingVisibilitySheet: Bool = false
    }
    @Published var uiState: UIState = UIState()
    
    @Published var isShowingCreateListSheet: Bool = false
    @Published var isShowingEmojiPicker: Bool = false
    @Published var canCreateList: Bool = false
    @Published var toast: Toast? = nil
    var isInitialized: Bool = false
    
    static func empty() -> ListViewModel {
        return ListViewModel(list: List.empty())
    }
    
    
    init(list: List){
        self.list=list
    }
    
    func initialize(userDataViewModel: UserDataViewModel){
        guard !isInitialized else { return }
        self.userDataViewModel=userDataViewModel
        self.list = List(name: "",
                         creatorId: userDataViewModel.currentUser?.id ?? UUID(),
                         emoji: nil,
                         visibility: ListVisibility.global)
    }

    var allItems: [ListItem] {
        var items = [ListItem]()
        
        // Add unsectioned items first
        items.append(contentsOf: list.unsectionedItems.map { ListItem.item($0) })
        
        // Add sections
        items.append(contentsOf: list.sections.map { ListItem.section($0) })
        
        return items
    }
    
    func toggleVisibilitySheet(){
        self.uiState.isShowingVisibilitySheet.toggle()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        self.list.unsectionedItems.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateListVisibilty(_ visibilty: ListVisibility){
        guard visibilty != self.list.visibility else { return }
        print("name: \(self.list.unsectionedItems[0].name) description: \(self.list.unsectionedItems[0].description)")
        
        var updatedList = self.list
        updatedList.visibility=visibilty
        
           
        self.list=updatedList
    }
    
    
    func postToSupabase() async throws -> UUID {
        let databaseObject = CreateListParams(list: self.list)
        
        do {
            return try await supabase
                .rpc("create_complete_list",
                     params: databaseObject)
                .execute()
                .value
        } catch {
            print(error)
            throw error
        }
    }
    
    func printOutDebug(){
        for (index, item) in self.list.unsectionedItems.enumerated() {
            let itemDescription = item.description ?? "No description"
            print("Index: \(index), Name: \(item.name), Description: \(itemDescription)")
        }
        print("------------------------------")
    }
    
}
