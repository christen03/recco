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
        case items
    }
    
    func toClientModel() -> List{
        List(
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
    let orderIndex: Int
    let items: [ItemQuery]
    
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case name
        case orderIndex = "order_index"
        case items
    }
    
    func toClientModel() -> Section {
        Section(
            name: name,
            items: items.map { $0.toClientModel() }
        )
    }
}

struct ItemQuery: Decodable {
    let itemId: UUID
    let name: String
    let description: String?
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case name
        case description
        case orderIndex = "order_index"
    }
    
    func toClientModel() -> Item {
        Item(
            name: name,
            description: description
        )
    }
}
