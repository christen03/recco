//
//  CurrentUser.swift
//  Recco
//
//  Created by Christen Xie on 8/27/24.
//

class CurrentUser {
    
    var user: User?
    
    static let instance: CurrentUser = {
        #if DEBUG 
        return CurrentUser(user: mockUser)
        #else
        return CurrentUser()
        #endif
    }()
    
    init() {}

    init(user: User) {
        self.user = user
    }
}
