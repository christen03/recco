//
//  Tag.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation

struct UserTag: Codable{
    let user_id: UUID
    let tag_id: Int
}

struct Tag: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let emoji: String
    let category: String
    
    enum CodingKeys: String, CodingKey {
         case id = "tag_id"
         case name
         case emoji
         case category
     }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
}
