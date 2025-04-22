//
//  ListUpsert.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation


struct CreateListParams: Encodable {
    
    let p_name: String
    let p_creator_id: UUID
    let p_emoji: String?
    let p_visibility: String
    let p_sections: [SectionInput]
    let p_unsectioned_items: [ItemInput]
    
    // Helper structs for JSON structure
    struct SectionInput: Encodable {
        let section_id: UUID
        let name: String
        let emoji: String?
        let items: [ItemInput]
    }
    
    struct ItemInput: Encodable {
        let item_id: UUID
        let name: String
        let description: String?
        let price_range: String?
        let is_starred: Bool
    }
    
    init(list: List) {
        self.p_name = list.name
        self.p_creator_id = list.creatorId
        self.p_emoji = list.emoji
        self.p_visibility = list.visibility.rawValue.lowercased()
        
        // Convert sections
        self.p_sections = list.sections.map { section in
            SectionInput(
                section_id: section.id,
                name: section.name,
                emoji: section.emoji,
                items: section.items.map {  item in
                    ItemInput(
                        item_id: item.id,
                        name: item.name,
                        description: item.description,
                        price_range: item.price?.rawValue.lowercased(),
                        is_starred: item.isStarred
                    )
                }
            )
        }
        
        // Convert unsectioned items
        self.p_unsectioned_items = list.unsectionedItems.map { item in
            ItemInput(
                item_id: item.id,
                name: item.name,
                description: item.description,
                price_range: item.price?.rawValue.lowercased(),
                is_starred: item.isStarred
            )
        }
    }
}


