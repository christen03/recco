//
//  AuthManager.swift
//  Recco
//
//  Created by chris10 on 4/21/25.
//

import Foundation
import Supabase
import Foundation
import Supabase

// MARK: - User Manager
class AuthManager {
    // Singleton instance
    static let shared = AuthManager()
    
    private init() {
        refreshSession()
    }
    
    private var cachedUserId: UUID?
    
    var currentUserId: UUID? {
        return cachedUserId
    }
    
    func fetchCurrentUserId() async throws -> UUID? {
        do {
            let session = try await supabase.auth.session
            self.cachedUserId = session.user.id
            return session.user.id
        } catch {
            print("Error fetching current user ID: \(error)")
            throw AuthError.noUserLoggedIn
        }
    }
    
    var isAuthenticated: Bool {
        return cachedUserId != nil
    }
    
    /// Refresh the session information
    /// Call this when app starts or returns to foreground
    func refreshSession() {
        Task {
            do {
                let session = try await supabase.auth.refreshSession()
                self.cachedUserId = session.user.id
                NotificationCenter.default.post(name: .userSessionRefreshed, object: nil)
            } catch {
                print("Failed to refresh session: \(error)")
                self.cachedUserId = nil
            }
        }
    }
    
    static func getUserId() async throws -> UUID? {
        if let cachedId = AuthManager.shared.currentUserId {
                return cachedId
            }
        return try await AuthManager.shared.fetchCurrentUserId()
        }
    
    /// Sign out current user
    func signOut() async throws {
        try await supabase.auth.signOut()
        self.cachedUserId = nil
        NotificationCenter.default.post(name: .userSignedOut, object: nil)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let userSessionRefreshed = Notification.Name("userSessionRefreshed")
    static let userSignedOut = Notification.Name("userSignedOut")
}

