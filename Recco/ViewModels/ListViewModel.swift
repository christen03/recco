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
    
    // TODO: heavy refactoring LOL
    func handleNewLine(atSection: Int?, atIndex: Int, listItemType: ListItemType) -> ListFocusIndex {
        if(listItemType == .sectionTitle){
            if let sectionIndex = atSection{
                self.list.sections[sectionIndex].items.insert(Item(name: ""), at: 0)
                return (section: sectionIndex, index: 0, isDescription: false, isSectionTitle: true)
            } else {
                self.list.unsectionedItems.insert(Item(name: ""), at: 0)
                return (section: nil, index: 0, isDescription: false, isSectionTitle: true)
            }
        } else if (listItemType == .itemDescription) {
            let newIndex = atIndex + 1
            if let sectionIndex = atSection {
                if(newIndex >= self.list.sections[sectionIndex].items.count){
                    self.list.sections[sectionIndex].items.append(Item(name:""))
                } else{
                    self.list.sections[sectionIndex].items.insert(Item(name: ""), at: newIndex)
                }
                return (section: atSection, index: newIndex, isDescription: false, isSectionTitle: false)
            } else {
                if(newIndex >= self.list.unsectionedItems.count){
                    self.list.unsectionedItems.append(Item(name: ""))
                } else {
                    self.list.unsectionedItems.insert(Item(name: ""), at: newIndex)
                }
                return (section: atSection, index: newIndex, isDescription: false, isSectionTitle: false)
            }
        } else {
            if let sectionIndex = atSection{
                if(self.list.sections[sectionIndex].items[atIndex].description == nil){
                    self.list.sections[sectionIndex].items[atIndex].description = ""
                }
                return (section: sectionIndex, index: atIndex, isDescription: true, isSectionTitle: false)
            }else {
                if (self.list.unsectionedItems[atIndex].description == nil){
                    self.list.unsectionedItems[atIndex].description = ""
                }
                return (section: nil, index: atIndex, isDescription: true, isSectionTitle: false)
            }
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
    
    func handleBackspaceEmptyString(atSection: Int?, atIndex: Int, listItemType: ListItemType) -> ListFocusIndex {
        if(listItemType == .sectionTitle){
            guard let sectionIndex = atSection else { return nil}
            let itemsToMove = self.list.sections[sectionIndex].items
            self.list.sections.remove(at: sectionIndex)
            if sectionIndex == 0 {
                list.unsectionedItems.append(contentsOf: itemsToMove)
            } else {
                self.list.sections[sectionIndex - 1].items.append(contentsOf: itemsToMove)
            }
            return nil
        } else if (listItemType == .itemDescription){
            return (section: atSection, index: atIndex, isDescription: false, isSectionTitle: false);
        } else {
            if let sectionIndex = atSection {
                self.list.sections[sectionIndex].items.remove(at: atIndex)
                if(atIndex == 0){
                    return (section: atSection, index: -1, isDescription: false, isSectionTitle: true)
                } else {
                    return (section: atSection, index: atIndex - 1, isDescription: true, isSectionTitle: false)
                }
            } else {
                self.list.unsectionedItems.remove(at: atIndex)
                return (section: nil, index: atIndex-1, isDescription: true, isSectionTitle: false)
            }
        }
    }
    
    func addNewSection(atSectionIndex: Int, atItemIndex: Int) -> ListFocusIndex {
        // Create a new section with no initial items
        var newSection = Section(name: "", items: [])

        if atSectionIndex == list.sections.count - 1 {
            // If adding a new section at the end
            if !list.sections.isEmpty && atItemIndex < list.sections.last!.items.count {
                newSection.items = Array(list.sections.last!.items[(atItemIndex+1)...])
                list.sections[atSectionIndex].items.removeSubrange((atItemIndex+1)...)
            }
            list.sections.append(newSection)
            return (section: list.sections.count - 1, index: -1, isDescription: false, isSectionTitle: true)
            
           // Handle unsectionedItems case
        } else if (atSectionIndex == -1) {
            list.sections.insert(newSection, at: 0)

            // Move items from the current section's items starting from atItemIndex to the new section
            if atItemIndex < list.unsectionedItems.count - 1 {
                let itemsToMove = Array(list.unsectionedItems[(atItemIndex+1)...])
                print(itemsToMove)
                list.sections[0].items.append(contentsOf: itemsToMove)
                list.unsectionedItems.removeSubrange((atItemIndex+1)...)
            }
            return (section: 0, index: -1, isDescription: false, isSectionTitle: true)
        } else {
            list.sections.insert(newSection, at: atSectionIndex+1)
            if atItemIndex < list.unsectionedItems.count - 1 {
                let itemsToMove = Array(list.sections[atSectionIndex].items[(atItemIndex+1)...])
                list.sections[atSectionIndex+1].items.append(contentsOf: itemsToMove)
                list.sections[atSectionIndex].items.removeSubrange((atItemIndex+1)...)
            }
            return (section: atSectionIndex+1, index: -1, isDescription: false, isSectionTitle: true)
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
