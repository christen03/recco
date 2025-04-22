//
//  UpdateList.swift
//  Recco
//
//  Created by chris10 on 4/10/25.
//

import Foundation


struct UpdateListParams: Encodable {
    let p_list_id: UUID  // Required for updates
    let p_name: String
    let p_emoji: String?
    let p_visibility: String
    let p_sections: [SectionUpdate]
    let p_unsectioned_items: [ItemUpdate]
    
    struct SectionUpdate: Encodable {
        let section_id: UUID?
        let name: String
        let emoji: String?
        let display_order: Int
        let items: [ItemUpdate]
        let is_deleted: Bool?
    }
    
    struct ItemUpdate: Encodable {
        let item_id: UUID?
        let name: String
        let description: String?
        let price_range: String?
        let is_starred: Bool
        let display_order: Int
        let is_deleted: Bool?
    }
    
    init(list: List) {
        self.p_list_id = list.id
        self.p_name = list.name
        self.p_emoji = list.emoji
        self.p_visibility = list.visibility.rawValue.lowercased()
        
        self.p_sections = list.sections.enumerated().map { index, section in
            SectionUpdate(
                section_id: section.id,
                name: section.name,
                emoji: section.emoji,
                display_order: index,
                items: section.items.enumerated().map { itemIndex, item in
                    ItemUpdate(
                        item_id: item.id,
                        name: item.name,
                        description: item.description,
                        price_range: item.price?.rawValue.lowercased(),
                        is_starred: item.isStarred,
                        display_order: itemIndex,
                        is_deleted: nil
                    )
                },
                is_deleted: nil
            )
        }
        
        self.p_unsectioned_items = list.unsectionedItems.enumerated().map { index, item in
            ItemUpdate(
                item_id: item.id,
                name: item.name,
                description: item.description,
                price_range: item.price?.rawValue.lowercased(),
                is_starred: item.isStarred,
                display_order: index,
                is_deleted: nil
            )
        }
    }
}
