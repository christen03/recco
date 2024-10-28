//
//  ListUpsert.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation

struct ListUpsert: Codable{
    let listId: UUID
    let name: String
    let creatorId: UUID
    let emoji: String?
    let visibility: String
    
    init(list: List){
        self.listId = UUID()
        self.name = list.name
        self.creatorId = list.creatorId
        self.emoji = list.emoji
        self.visibility = list.visibility.rawValue
    }
    
    enum CodingKeys: String, CodingKey {
        case listId = "list_id"
        case name
        case creatorId = "creator_id"
        case emoji
        case visibility
    }
}

struct SectionUpsert: Codable {
    let sectionId: UUID
    let listId: UUID
    let name: String
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case sectionId = "section_id"
        case listId = "list_id"
        case name
        case orderIndex = "order_index"
    }
}

struct ItemUpsert: Codable {
    let itemId: UUID
    let listId: UUID
    let sectionId: UUID?
    let name: String
    let description: String?
    let orderIndex: Int
    
    enum CodingKeys: String, CodingKey {
       case itemId = "item_id"
        case listId = "list_id"
        case sectionId = "section_id"
        case name
        case description
        case orderIndex = "order_index" 
    }
}
