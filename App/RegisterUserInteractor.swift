//
//  RegisterUserInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class RegisterUserInteractor: RepositoryInteractor {

    var onRegisterSuccess: (() -> ())?
    var onRegisterFailure: (() -> ())?
	
	func registerWithCredentials (credentials: UserCredentials) {
		
		data.registerWithCredentials(credentials) { [weak self] (error) in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                RCLogO(errorString)
                self?.onRegisterFailure?()
            } else {
                self?.onRegisterSuccess?()
            }
        }
	}
}
