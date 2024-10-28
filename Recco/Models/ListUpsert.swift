//
//  ListUpsert.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation


struct CreateListParams: Encodable {
    
    let p_list_id: UUID
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
        let items: [ItemInput]
    }
    
    struct ItemInput: Encodable {
        let item_id: UUID
        let name: String
        let description: String?
    }
    
    init(list: List) {
        self.p_list_id = list.id
        self.p_name = list.name
        self.p_creator_id = list.creatorId
        self.p_emoji = list.emoji
        self.p_visibility = list.visibility.rawValue
        
        // Convert sections
        self.p_sections = list.sections.map { section in
            SectionInput(
                section_id: section.id,
                name: section.name,
                items: section.items.map { item in
                    ItemInput(
                        item_id: item.id,
                        name: item.name,
                        description: item.description
                    )
                }
            )
        }
        
        // Convert unsectioned items
        self.p_unsectioned_items = list.unsectionedItems.map { item in
            ItemInput(
                item_id: item.id,
                name: item.name,
                description: item.description
            )
        }
    }
}

