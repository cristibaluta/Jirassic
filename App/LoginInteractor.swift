//
//  LoginController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 12/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class LoginInteractor: RepositoryInteractor {
    
    var onLoginSuccess: (() -> ())?
    var onLoginFailure: (() -> ())?
	
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
    
	func logout() {
		data.logout()
	}
}
