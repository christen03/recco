//
//  ListViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/25/24.
//

import Foundation

enum ListVisibility: String, CaseIterable {
    // Named global becuase 'public' is a reserved keyword
    case global = "🌐 Public"
    case friends = "👥 All Friends"
    case restricted = "🔒 Restricted"
    
    
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
    
    @Published var list: List {
        didSet {
            validateListFields()
        }
    }
    @Published var isShowingCreateListSheet: Bool = false
    @Published var isShowingEmojiPicker: Bool = false
    @Published var canCreateList: Bool = false
    @Published var isShowingVisibiltySheet: Bool = false
    
    init(){
        self.list = List(name: "",
                         creatorId: CurrentUser.instance.user!.id,
                         emoji: nil,
                         visibility: ListVisibility.global)
    }
    
    // For testing previews
    init(userId: String, selectedEmoji: String, listName: String, sections: [Section], items: [Item]){
        self.list = List(name: listName, creatorId: CurrentUser.instance.user!.id, emoji: selectedEmoji, visibility: ListVisibility.global, sections: sections, items: items)
    }
    
    var allItems: [ListItem] {
           var items = [ListItem]()
           
           // Add unsectioned items first
           items.append(contentsOf: list.unsectionedItems.map { ListItem.item($0) })
           
           // Add sections
           items.append(contentsOf: list.sections.map { ListItem.section($0) })
           
           return items
       }
    
    func deleteItem(at offsets:IndexSet){
        self.list.unsectionedItems.remove(atOffsets: offsets)
    }
    
//    func move(from source: IndexSet, to destination: Int) {
//        self.list.unsectionedItems.move(fromOffsets: source, toOffset: destination)
//       }
//    
    func toggleFavoriteForIndex(at index: Int){
        self.list.unsectionedItems[index].isStarred.toggle()
        print("Setting starred range for index \(index)")
    }
    
    func setPriceRange(forIndex index: Int, to priceRange: PriceRange){
        print("Setting price range for index \(index)")
        self.list.unsectionedItems[index].price = priceRange
    }
    
    private func validateListFields(){
        self.canCreateList = (list.emoji != nil && !list.name.isEmpty)
    }
    
    
    func move(from source: IndexSet, to destination: Int) {
           var items = allItems
           items.move(fromOffsets: source, toOffset: destination)
           
           // Rebuild the unsectionedItems and sections arrays based on the new order
           var newUnsectionedItems = [Item]()
           var newSections = [Section]()
           
           for listItem in items {
               switch listItem {
               case .item(let item):
                   newUnsectionedItems.append(item)
               case .section(let section):
                   newSections.append(section)
               default:
                   break
               }
           }
           
           list.unsectionedItems = newUnsectionedItems
           list.sections = newSections
       }
}
