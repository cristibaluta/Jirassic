//
//  LoginPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol LoginPresenterInput {
    
    func loginWithCredentials (credentials: UserCredentials)
    func cancelScreen()
}

protocol LoginPresenterOutput {
    
    func showLoadingIndicator (show: Bool)
}

class LoginPresenter {
    
    var userInterface: LoginPresenterOutput?
    var wireframe: Wireframe?
    var onLoginSuccess: (() -> ())?
    var onExit: (() -> ())?
}

extension LoginPresenter: LoginPresenterInput {
    
    func loginWithCredentials (credentials: UserCredentials) {
        
        userInterface?.showLoadingIndicator(true)
        
        let login = LoginInteractor(data: remoteRepository)
        login.onLoginSuccess = {
            self.userInterface?.showLoadingIndicator(false)
            self.onLoginSuccess?()
        }
        login.onLoginFailure = {
            self.userInterface?.showLoadingIndicator(false)
        }
        login.loginWithCredentials(credentials)
    }
    
    func cancelScreen() {
        self.onExit?()
    }
}