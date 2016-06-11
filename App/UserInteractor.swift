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
    
    func currentUser() -> User {
        return data.currentUser()
    }
    
    func loginWithCredentials (credentials: UserCredentials) {
        
        data.loginWithCredentials(credentials) { [weak self] (error: NSError?) in
            
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
        data.logout()
    }
    
    private func register (credentials: UserCredentials) {
        
        let registerInteractor = RegisterUserInteractor(data: data)
        registerInteractor.onRegisterSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        registerInteractor.onRegisterFailure = { [weak self] in
            self?.onLoginFailure?()
        }
        registerInteractor.registerWithCredentials(credentials)
    }
    
}
