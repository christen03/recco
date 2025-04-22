//
//  ListQuery.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation

struct ListQuery: Decodable {
    let listId: UUID
    let name: String
    let creatorId: UUID
    let emoji: String?
    let visibility: String
    let sections: [SectionQuery]
    let items: [ItemQuery]
    
    enum CodingKeys: String, CodingKey {
        case listId = "id"
        case name
        case creatorId = "creator_id"
        case emoji
        case visibility
        case sections
        case items = "unsectioned_items"
    }
    
    func toClientModel() -> List{
        List(
            id: listId,
            name: name,
            creatorId: creatorId,
            emoji: emoji,
            visibility: ListVisibility(rawValue: visibility) ?? .global,
            sections: sections.map { $0.toClientModel() },
            items: items.map { $0.toClientModel() }
        )
    }
}

struct SectionQuery: Decodable {
    let sectionId: UUID
    let name: String
    let emoji: String?
    let displayOrder: Int
    let items: [ItemQuery]
    
    enum CodingKeys: String, CodingKey {
        case sectionId = "id"
        case name
        case emoji
        case displayOrder = "display_order"
        case items
    }
    
    func toClientModel() -> Section {
        Section(
            id: sectionId,
            name: name,
            emoji: emoji,
            items: items.map { $0.toClientModel() }
        )
    }
}

struct ItemQuery: Decodable {
    let itemId: UUID
    let name: String
    let description: String?
    let displayOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case itemId = "id"
        case name
        case description
        case displayOrder = "display_order"
    }
    
    func toClientModel() -> Item {
        Item(
            id: itemId,
            name: name,
            description: description
        )
    }
}
