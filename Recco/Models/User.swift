//
//  User.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import Foundation

class User: Codable{
    let id: UUID
    var firstName: String
    var lastName: String
    var username: String
    var profilePictureUrl: URL
    var email: String?
    var phoneNumber: String?
    
    init(id: UUID, firstName: String, lastName: String, username: String, profilePictureUrl: URL, email: String, phoneNumber: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.profilePictureUrl = profilePictureUrl
        self.email = email.isEmpty ? nil : email
        self.phoneNumber = phoneNumber.isEmpty ? nil : phoneNumber
    }
    
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
