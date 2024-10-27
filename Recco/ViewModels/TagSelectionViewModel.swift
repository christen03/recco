//
//  TagSelectionViewModel.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation
@MainActor
class TagSelectionViewModel: ObservableObject {

    @Published var toast: Toast? = nil
    @Published var isFetchingTags: Bool = false
    @Published var isSavingTags: Bool = false
    @Published var isTagsError: String? = nil
    @Published var selectedTags: Set<Tag> = []
    @Published var availableTags: [String:[Tag]] = [:]
    
    func toggleTag(tag: Tag){
        if(selectedTags.contains(tag)){
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    func fetchAllTags() async {
        self.isFetchingTags = true
        defer {isFetchingTags = false}
        Task {
            do {
                let response: [Tag] = try await supabase
                    .from("tags")
                    .select()
                    .order("category")
                    .order("name")
                    .execute()
                    .value
                
                availableTags = Dictionary(grouping: response) { tag in
                    tag.category
                }
            } catch {
                print(error)
                isTagsError = "Failed to load tags: \(error.localizedDescription)"
            }
        }
    }
    
    func applyTagChanges(userId: UUID) async -> Bool {
        self.isSavingTags = true
        defer {self.isSavingTags = false}
        do {
            try await supabase
                .from("user_tags")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            
            if !selectedTags.isEmpty {
                let tagValues: [UserTag] = selectedTags.map { tag in
                    UserTag(user_id: userId, tag_id: tag.id)
                }
                
                try await supabase
                    .from("user_tags")
                    .insert(tagValues)
                    .execute()
            }
            toast = Toast(style: .success, message: "Tags updated successfully")
            return true
        } catch {
            toast = Toast(style: .error, message: "Error updating tags")
            print("Error updating tags: \(error)")
            return false
        }
    }
}
