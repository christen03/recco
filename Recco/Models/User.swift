//
//  User.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import Foundation

class User: Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: UUID
    var firstName: String
    var lastName: String
    var username: String
    var profilePictureUrl: URL
    var email: String?
    var phoneNumber: String?
    var tags: [Tag]
    
    init(id: UUID, firstName: String, lastName: String, username: String, profilePictureUrl: URL, email: String, phoneNumber: String, tags: [Tag]) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.profilePictureUrl = profilePictureUrl
        self.email = email.isEmpty ? nil : email
        self.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
        self.tags = tags
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case profilePictureUrl = "profile_picture_url"
        case email
        case phoneNumber = "phone_number"
        case tags
    }
}

struct CreateUserParams: Encodable {
    let id: UUID
    let firstName: String
    let lastName: String
    let username: String
    let profilePictureUrl: URL
    let email: String?
    let phoneNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case profilePictureUrl = "profile_picture_url"
        case email
        case phoneNumber = "phone_number"
    }
}


struct SupabaseUserResponse: Decodable {
    let id: UUID
        let firstName: String
        let lastName: String
        let username: String
        let profilePictureUrl: URL
        let email: String?
        let phoneNumber: String?
//        let userTags: [UserTagResponse]
        
        enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case firstName = "first_name"
            case lastName = "last_name"
            case username
            case profilePictureUrl = "profile_picture_url"
            case email
            case phoneNumber = "phone_number"
//            case userTags = "user_tags"
        }
        
        // Convert to your User model
        func toUser() -> User {
            User(
                id: id,
                firstName: firstName,
                lastName: lastName,
                username: username,
                profilePictureUrl: profilePictureUrl,
                email: email ?? "",
                phoneNumber: phoneNumber ?? "",
                tags: []
//                tags: userTags.map { $0.tags }
            )
        }
    }

struct UserTagResponse: Decodable {
        let tags: Tag
}
