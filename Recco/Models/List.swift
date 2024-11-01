//
//  List.swift
//  Recco
//
//  Created by Christen Xie on 8/27/24.
//

import Foundation

struct Item: Hashable, Identifiable {
    let id: UUID
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
    
    init(id: UUID? = nil, name: String, description: String, price: PriceRange, isStarred: Bool? = false){
        self.id = id ?? UUID()
        self.name = name
        self.description = description
        self.price=price
        self.isStarred=isStarred ?? false
    }
}

struct Section: Hashable, Identifiable {
    let id: UUID
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

enum ListItem: Identifiable {
    case header(String)          // Section header with the section name
    case item(Item)              // Regular item
    case section(Section)        // Entire section with items
    
    var id: UUID {
        switch self {
        case .header(let name):
            return UUID()
        case .item(let item):
            return item.id
        case .section(let section):
            return UUID()
        }
    }
}


struct List: Identifiable, Equatable, Hashable {
    let id: UUID
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
                items: []
            )
        }
}

