//
//  AuthViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/18/24.
//

import Foundation

// CURRENTLY UNUSED
extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case currentUser
    }
    
    func saveUser(_ user: User, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            self.set(data, forKey: key)
        } catch {
            print("Failed to encode user: \(error.localizedDescription)")
        }
    }
    
    func getUser(forKey key: String) -> User? {
        if let data = self.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.self, from: data)
                return user
            } catch {
                print("Failed to decode user: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func removeUser(forKey key: String) {
        self.removeObject(forKey: key)
    }
}
// END CURRENTLY UNUSED


class UserDataViewModel: BaseSupabase {
    
    @Published var isUserAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    
    override init(){
        super.init()
        Task{
            let session = try? await supabase.auth.session
            guard let sessionData = session else { return }
            let userResponse =  try await fetchUserDataFromSupabase(userId: sessionData.user.id)
            await MainActor.run {
                self.currentUser = userResponse.toUser()
                self.isUserAuthenticated = true
            }
        }
    }
    
    init(user: User){
        self.currentUser=user
    }
    
    func login(){
        self.isUserAuthenticated=true
    }
    
    func signOut(){
        Task{
            do{
                try await supabase.auth.signOut()
                await MainActor.run{
                    self.isUserAuthenticated=false
                }
            } catch {
                // TODO: also implement failure here
                print("Failed to sign user out")
            }
        }
    }
    
    func fetchUserDataFromSupabase(userId: UUID) async throws -> SupabaseUserResponse {
        do{
            return try await supabase
                .from("users")
                .select("""
user_id,
first_name,
last_name,
username,
profile_picture_url,
email,
phone_number,
user_tags (
    tags (
        tag_id,
        name,
        emoji,
        category
        )
    )
""")
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            
        } catch {
            print("Error fetching user data, \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateUserProfilePictureLocally(newUrl: URL){
        self.currentUser?.profilePictureUrl=(newUrl)
    }
    
    @MainActor
    func updateUserTags(newTags: Set<Tag>){
        if let updatedUser = currentUser{
            updatedUser.tags=Array(newTags)
            self.currentUser=updatedUser
        }
    }
    
}
