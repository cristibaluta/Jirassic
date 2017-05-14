//
//  UserInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 03/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class UserInteractor: RepositoryInteractor {
    
    var onLoginSuccess: (() -> ())?
    var onLoginFailure: (() -> ())?
    
    func getUser(_ completion: @escaping ((_ user: User?) -> Void)) {
        self.repository.getUser(completion)
    }
    
    func loginWithCredentials (_ credentials: UserCredentials) {
        
        self.repository.loginWithCredentials(credentials) { [weak self] (error: NSError?) in
            
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                RCLogO(errorString)
                self?.register(credentials)
            } else {
                self?.onLoginSuccess?()
            }
        }
    }
    
    func logout() {
        self.repository.logout()
    }
    
    fileprivate func register (_ credentials: UserCredentials) {
        
        let registerInteractor = RegisterUserInteractor(repository: self.repository)
        registerInteractor.onRegisterSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        registerInteractor.onRegisterFailure = { [weak self] in
            self?.onLoginFailure?()
        }
        registerInteractor.registerWithCredentials(credentials)
    }
    
}
