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
    
    func move(from source: IndexSet, to destination: Int) {
        self.list.unsectionedItems.move(fromOffsets: source, toOffset: destination)
    }
    //
    func toggleFavoriteForIndex(atSection: Int?, atIndex: Int){
        print("Setting toggle for index \(atSection) at index \(atIndex)")
        if let sectionIndex = atSection{
            self.list.sections[sectionIndex].items[atIndex].isStarred.toggle()
        } else {
            self.list.unsectionedItems[atIndex].isStarred.toggle()
        }
    }
    
    func setPriceRange(atSection: Int?, atIndex: Int, to priceRange: PriceRange){
        if let sectionIndex = atSection{
            self.list.sections[sectionIndex].items[atIndex].price = priceRange
        } else{
            self.list.unsectionedItems[atIndex].price = priceRange
        }
    }
    
    func validateListFields(){
        self.canCreateList = (list.emoji != nil && !list.name.isEmpty)
    }
    
    
    
    func handleSectionSubmit(atSection: Int) -> EditListView.FocusField{
        self.list.sections[atSection].items.insert(Item(name: ""), at: 0)
        return .name(section: atSection, index: 0)
    }
    
    func handleNameSubmit(atSection: Int?, atIndex: Int) -> ListFocusIndex {
        if let sectionIndex = atSection{
            if(self.list.sections[sectionIndex].items[atIndex].description == nil){
                self.list.sections[sectionIndex].items[atIndex].description = ""
            }
            return (section: sectionIndex, index: atIndex, isDescription: true)
        }else {
            if (self.list.unsectionedItems[atIndex].description == nil){
                self.list.unsectionedItems[atIndex].description = ""
            }
            return (section: nil, index: atIndex, isDescription: true)
        }
    }
    
    func handleDescriptionSubmit(atSection: Int?, atIndex: Int) -> ListFocusIndex {
        let newIndex = atIndex+1
        if let sectionIndex = atSection {
            self.list.sections[sectionIndex].items.insert(Item(name: ""), at: newIndex)
            return (section: atSection, index: newIndex, isDescription: false)
        } else {
            self.list.unsectionedItems.insert(Item(name: ""), at: newIndex)
            return (section: atSection, index: newIndex, isDescription: false)
        }
    }
    
    func setPreviousDescriptionToNilIfEmpty(atSection: Int?, atIndex: Int) {
        if let sectionIndex = atSection {
            if(self.list.sections[sectionIndex].items[atIndex].description!.isEmpty){
                self.list.sections[sectionIndex].items[atIndex].description = nil
            }
        } else {
            if(self.list.unsectionedItems[atIndex].description!.isEmpty){
                self.list.unsectionedItems[atIndex].description = nil
            }
        }
    }
    
}
