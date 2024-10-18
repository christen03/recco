//
//  AuthViewModel.swift
//  Recco
//
//  Created by Christen Xie on 8/18/24.
//

import Foundation

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

// TODO: Refactor to not include currentUser
class UserDataViewModel: BaseSupabase {
    
    @Published var isUserAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    
    override init(){
        super.init()
        Task{
            print("Fetching session")
            let session = try? await supabase.auth.session
            guard let sessionData = session else { return }
            await MainActor.run {
                self.isUserAuthenticated = true
                loadCachedUser()
            }
            refreshUserData(userId: sessionData.user.id)
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
    
    // Query is returning before loading cached user and currentUser is getting set to query and then cachedUser
    func loadCachedUser(){
        if let userData = UserDefaults.standard.getUser(forKey: UserDefaults.UserDefaultKeys.currentUser.rawValue){
            currentUser = userData
            CurrentUser.instance.updateUser(user: userData)
        }
    }
    
    func refreshUserData(userId: UUID) {
        Task {
            do {
                let refreshedUser = try await self.fetchUserDataFromSupabase(userId: userId)
                UserDefaults.standard.saveUser(refreshedUser, forKey: UserDefaults.UserDefaultKeys.currentUser.rawValue)
               await MainActor.run{
                    self.currentUser = refreshedUser
                }
            } catch {
                // TODO: Implement retry/error messaging
                print("Failed to fetch updated user daata")
            }
        }
    }
    
    func fetchUserDataFromSupabase(userId: UUID) async throws -> User {
        return try await supabase
            .from("users")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
    }
    
    func updateUserProfilePictureLocally(newUrl: URL){
        if let user = UserDefaults.standard.getUser(forKey: "currentUser") {
            user.profilePictureUrl = newUrl
            UserDefaults.standard.saveUser(user, forKey: "currentUser")
            print("Updated User: \(user.firstName) \(user.lastName)")
        } else {
            print("No user found in UserDefaults")
        }
    }
    
    
}
