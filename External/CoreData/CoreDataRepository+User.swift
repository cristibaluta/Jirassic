//
//  CoreDataRepository+User.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataRepository: RepositoryUser {
    
    func getUser (_ completion: @escaping ((_ user: User?) -> Void)) {
        
        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
        let cusers: [CUser] = queryWithPredicate(userPredicate, sortDescriptors: nil)
        if let cuser = cusers.last {
            completion( User(email: cuser.email, userId: cuser.userId) )
        } else {
            completion(nil)
        }
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func logout() {
        
    }
}
