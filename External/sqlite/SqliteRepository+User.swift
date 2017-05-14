//
//  SqliteRepository+User.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositoryUser {
    
    func getUser(_ completion: @escaping ((_ user: User?) -> Void)) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func logout() {
        fatalError("This method is not applicable to local Repository")
    }
}
