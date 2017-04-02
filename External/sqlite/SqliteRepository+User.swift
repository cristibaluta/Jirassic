//
//  SqliteRepository+User.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositoryUser {
    
    func currentUser() -> User {
        
        //        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
        //        let cusers: [RUser] = queryWithPredicate(userPredicate, sortDescriptors: nil)
        //        if let cuser = cusers.last {
        //            return User(isLoggedIn: true, email: cuser.email, userId: cuser.userId, lastSyncDate: cuser.lastSyncDate)
        //        }
        
        return User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func logout() {
    }
}
