//
//  List.swift
//  Recco
//
//  Created by Christen Xie on 8/27/24.
//

import Foundation

struct Item: Hashable, Identifiable {
    let id = UUID()
    var name: String
    var description: String?
    var price: PriceRange? = nil
    var isStarred: Bool = false
    var tags: [String]?
    var sources: [String]?
    
    init(name: String, description: String? = nil, tags: [String]? = nil, sources: [String]? = nil) {
        self.name = name
        self.description = description
        self.tags = tags
        self.sources = sources
    }
    
    init(name: String, description: String, price: PriceRange, isStarred: Bool? = false){
        self.name = name
        self.description = description
        self.price=price
        self.isStarred=isStarred ?? false
    }
}

struct Section: Hashable, Identifiable {
    let id = UUID()
    var name: String
    var emoji: String?
    var items: [Item]
    
    init(name: String, emoji: String? = nil, items: [Item] = []) {
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


struct List {
    var name: String
    let creatorId: UUID
    var emoji: String?
    var visibility: ListVisibility
    var sections: [Section]
    var unsectionedItems: [Item]
    
    init(name: String, creatorId: UUID, emoji: String? = nil, visibility: ListVisibility, sections: [Section] = [], items: [Item] = []) {
        self.name = name
        self.creatorId = creatorId
        self.emoji = emoji
        self.visibility = visibility
        self.sections = sections
        self.unsectionedItems = items
    }
}

