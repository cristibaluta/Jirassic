//
//  CloudKitRepository+User.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

extension CloudKitRepository: RepositoryUser {
    
    func getUser (_ completion: @escaping ((_ user: User?) -> Void)) {
        
        CKContainer.default().accountStatus(completionHandler: { (accountStatus, error) in
            DispatchQueue.main.async {
                if accountStatus == .available {
                    completion( User(email: nil, userId: nil) )
                } else {
                    completion( nil )
                }
            }
        })
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        
    }
    
    func logout() {
        user = nil
        privateDB = nil
        customZone = nil
    }
}
