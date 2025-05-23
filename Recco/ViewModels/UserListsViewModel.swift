//
//  UserListsViewModel.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import Foundation

class UserListsViewModel: ObservableObject {
    
    @Published var userLists: [List] = []
    @Published var isFetching: Bool = false
    
    init(){
        Task{
            await fetchUsersLists()
        }
    }
    
    let fetchListsQuery: String =
        """
            id, 
            name, 
            creator_id, 
            emoji, 
            visibility, 
            sections(
                id, 
                name, 
                emoji,
                display_order,
                items(*)
            ),
            unsectioned_items(
                id,
                name,
                description,
                display_order,
                price_range,
                is_starred
            )
        """
    
    private func userListsQuery(userId: UUID) async throws -> [ListQuery] {
        do{
            let data: [ListQuery] = try await supabase
                .from("lists")
                .select(fetchListsQuery)
                .eq("creator_id",value: userId)
                .order("updated_at", ascending: false)
                .order("display_order", ascending: true, referencedTable: "sections")
                .order("display_order", ascending: true, referencedTable: "unsectioned_items")
                .execute()
                .value
            return data
        } catch {
            print("fetchUserLists error:  \(error)")
            throw error
        }
    }
    
    @MainActor
    func fetchUsersLists() async {
        Task{
            let userId = try await supabase.auth.session.user.id
            let response = try await self.userListsQuery(userId: userId)
                self.userLists=response.map{$0.toClientModel()}
                self.isFetching = false;
        }
    }
}
