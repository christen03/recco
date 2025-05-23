//
//  SupabaseUserManager.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import Foundation
import Supabase
import SwiftUI

enum ImageUploadError: Error {
    case missingUserId
}

class SupabaseUserManager {
    
    struct UpsertProfilePictureParams: Encodable {
        let id: UUID
        let profilePictureUrl: URL
        
        enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case profilePictureUrl = "profile_picture_url"
        }
    }
    
    func createUserInSupabase(userData: CreateUserParams) async throws{
        try await supabase
            .from("users")
            .insert(userData)
            .execute()
    }
    
    func uploadProfilePictureToSupabase(imageData: Data) async throws  -> URL{
        guard let userId = supabase.auth.currentSession?.user.id else {
            throw ImageUploadError.missingUserId
        }
        let fileName = "\(userId).jpg"
        let response = try await supabase.storage
            .from("profile-pictures")
            .upload(
                path: fileName,
                file: imageData
            )
        let filePath = URL(
            string: Constants.SUPABASE_STORAGE_BASE_URL+response.fullPath)!
        do{
            try await supabase
                .from("users")
                .update(["profile_picture_url": filePath])
                .eq("user_id", value: userId)
                .execute()
        } catch {
            print(error)
        }
        return filePath
    }
    
    func checkUserExists(email: String, phone: String) async throws -> Bool{
           
        var query = supabase.from("users").select("*")
        if !email.isEmpty {
            query = query.eq("email", value: email)
        } else if !phone.isEmpty {
            query = query.eq("phone_number", value: phone)
        }
        
        let response: [User] = try await query.execute().value
        print(response, "resp")
        return !response.isEmpty
    }
}
