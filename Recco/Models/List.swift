//
//  List.swift
//  Recco
//
//  Created by Christen Xie on 8/27/24.
//

import Foundation

struct Item: Hashable, Identifiable {
    var id: UUID
    var name: String
    var description: String?
    var price: PriceRange? = nil
    var isStarred: Bool = false
    var tags: [String]?
    var sources: [String]?
    
    init(id: UUID? = nil, name: String, description: String? = nil, tags: [String]? = nil, sources: [String]? = nil) {
        self.id = id ?? UUID()
        self.name = name
        self.description = description
        self.tags = tags
        self.sources = sources
    }
    
    init(id: UUID? = nil, name: String, description: String, price: PriceRange? = nil, isStarred: Bool? = false){
        self.id = id ?? UUID()
        self.name = name
        self.description = description
        self.price=price
        self.isStarred=isStarred ?? false
    }
}

struct Section: Hashable, Identifiable {
    var id: UUID
    var name: String
    var emoji: String?
    var items: [Item]
    
    init(id: UUID? = nil, name: String, emoji: String? = nil, items: [Item] = []) {
        self.id = id ?? UUID()
        self.name = name
        self.emoji = emoji
        self.items = items
    }
}

struct List: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    let creatorId: UUID
    var emoji: String?
    var visibility: ListVisibility
    var sections: [Section]
    var unsectionedItems: [Item]
    
    init(id: UUID? = nil, name: String, creatorId: UUID, emoji: String? = nil, visibility: ListVisibility, sections: [Section] = [], items: [Item] = []) {
        self.id = id ?? UUID()
        self.name = name
        self.creatorId = creatorId
        self.emoji = emoji
        self.visibility = visibility
        self.sections = sections
        self.unsectionedItems = items
    }
    
    static func empty() -> List {
            List(
                name: "",
                creatorId: UUID(),
                emoji: nil,
                visibility: .global,
                sections: [],
                items: [Item(name: "", description: "")]
            )
        }
}

extension List {
    mutating func addSection(_ section: Section, at index: Int? = nil) {
        if let index = index {
            sections.insert(section, at: index)
        } else {
            sections.append(section)
        }
//        self.update()
    }
    
    mutating func removeSection(at index: Int) -> Section {
        let section = sections.remove(at: index)
//        self.update()
        return section
    }
    
    mutating func moveItemToUnsectioned(_ item: Item) {
        unsectionedItems.append(item)
//        self.update()
    }
//    
}


extension Section {
    mutating func addItem(_ item: Item, at index: Int? = nil) {
        if let index = index, index < items.count {
            items.insert(item, at: index)
        } else {
            items.append(item)
        }
//        self.update()
    }
    
    mutating func removeItem(at index: Int) -> Item {
        let item = items.remove(at: index)
//        self.update()
        return item
    }
    
    mutating func moveItems(from: Int, to: Int) {
        items.move(fromOffsets: IndexSet(integer: from), toOffset: to)
//        self.update()
    }
    
    mutating func splitAt(index: Int) -> Section {
        let newSection = Section(name: "", items: Array(items[(index + 1)...]))
        items.removeSubrange((index + 1)...)
//        self.update()
        return newSection
    }
    
}
extension Item {
    mutating func toggleFavorite() {
        self.isStarred.toggle()
//        self.update()
    }
    
    mutating func setPriceRange(_ range: PriceRange) {
        self.price = range
//        self.update()
    }
    
    mutating func setDescription(_ description: String) {
        if(self.description == nil){
            self.description = description
        }
    }
//        self.update()
    
    mutating func deleteDescription() {
        self.description=nil
    }
}
