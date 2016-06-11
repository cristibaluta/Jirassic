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
        
        let interactor = UserInteractor(data: localRepository)
        interactor.onLoginSuccess = {
            self.userInterface?.showLoadingIndicator(false)
        }
        let user = interactor.currentUser()
        user.isLoggedIn ? interactor.logout() : interactor.loginWithCredentials(credentials)
    }
}
