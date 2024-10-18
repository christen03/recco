//
//  CurrentUser.swift
//  Recco
//
//  Created by Christen Xie on 8/27/24.
//

import Foundation

class CurrentUser {
    static let instance = CurrentUser()

    var user: User?

    private init() {}
    
    func updateUser(user: User) {
        self.user = user
    }
    
    func getUserId() -> UUID? {
        return user?.id
    }
    
    func getUsername() -> String? {
        return user?.username
    }
    
    func setProfilePictureUrl(newUrl: URL){
        user?.profilePictureUrl = newUrl
    }
    
}
