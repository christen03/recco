//
//  AuthViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/18/24.
//

import Foundation
import Supabase


class UserDataViewModel: ObservableObject {
    
    @Published var isUserAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    
    init(){
        Task{
            await fetchUserDataFromSupabase()
        }
    }
    
    init(user: User){
        self.currentUser=user
    }
    
    func signOut(){
        Task{
            do{
                try await supabase.auth.signOut()
            } catch {
                print("Failed to sign user out")
            }
        }
    }
    
    func fetchUserDataFromSupabase() async {
        do {
            let userId = try await supabase.auth.session.user.id
            let userResponse: SupabaseUserResponse = try await supabase
                .from("users")
                .select("*")
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            await MainActor.run {
                self.currentUser = userResponse.toUser()
                self.isUserAuthenticated=true
            }
        }
        catch {
            if let error = error as? PostgrestError {
                if (error.code == "PGRST116"){
                    await MainActor.run{
                        self.isUserAuthenticated=true
                    }
                }
            }
        }
    }
    
    @MainActor
    func updateUserTags(newTags: Set<Tag>){
        if let updatedUser = currentUser{
            updatedUser.tags=Array(newTags)
            self.currentUser=updatedUser
        }
    }
    
}
