//
//  SettingsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsPresenterInput {
    
    func login (credentials: UserCredentials)
}

protocol SettingsPresenterOutput {
    
    func showLoadingIndicator (show: Bool)
}

class SettingsPresenter {
    
    var userInterface: SettingsPresenterOutput?
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func login (credentials: UserCredentials) {
        
        let user = ReadUserInteractor().currentUser()
        let login = LoginInteractor(data: localRepository)
        login.onLoginSuccess = {
            self.userInterface?.showLoadingIndicator(false)
        }
        user.isLoggedIn ? login.logout() : login.loginWithCredentials(credentials)
    }
}
