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
        self.isFetching=true
        Task{
            let userId = try await supabase.auth.session.user.id
            let response = try await fetchUserLists(userId: userId)
            await MainActor.run{
                self.userLists=response.map{$0.toClientModel()}
                self.isFetching = false;
            }
        }
    }
    
    let fetchListsQuery: String =
    """
            list_id, 
            name, 
            creator_id, 
            emoji, 
            visibility, 
            sections(
                section_id, 
                name, 
                order_index,
                items(*)
            ),
            items(
                item_id,
                name,
                description,
                order_index
            )
        """
    
    func fetchUserLists(userId: UUID) async throws -> [ListQuery] {
        do{
            let data: [ListQuery] = try await supabase
                .from("lists")
                .select(fetchListsQuery)
                .eq("creator_id",value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            print(data)
            return data
        } catch {
            print("fetchUserLists error:  \(error.localizedDescription)")
            throw error
        }
    }
}
