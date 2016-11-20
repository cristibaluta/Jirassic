//
//  SettingsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsPresenterInput {
    
    func login (_ credentials: UserCredentials)
    func loadJitInfo()
    func installJit()
    func uninstallJit()
    func showSettings()
    func saveAppSettings (_ settings: Settings)
}

protocol SettingsPresenterOutput {
    
    func showLoadingIndicator (_ show: Bool)
    func setJitIsInstalled (_ installed: Bool)
    func setJiraSettings (_ settings: JiraSettings)
    func showAppSettings (_ settings: Settings)
}

class SettingsPresenter {
    
    fileprivate var jitInteractor = JitInteractor()
    var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func login (_ credentials: UserCredentials) {
        
//        let interactor = UserInteractor(data: localRepository)
//        interactor.onLoginSuccess = {
//            self.userInterface?.showLoadingIndicator(false)
//        }
//        let user = interactor.currentUser()
//        user.isLoggedIn ? interactor.logout() : interactor.loginWithCredentials(credentials)
    }
    
    func loadJitInfo() {
        
        jitInteractor.isInstalled { installed in
            
            DispatchQueue.main.sync {
                self.userInterface!.setJitIsInstalled( installed )
            }
            if installed {
                self.jitInteractor.getJiraSettings { dict in
                    let settings = JiraSettings(url: dict["url"],
                                                user: dict["user"],
                                                separator: dict["separator"])
                    self.jiraSettingsDidLoad(settings)
                }
            } else {
                self.jiraSettingsDidLoad(JiraSettings())
            }
        }
    }
    
    func installJit() {
        
        jitInteractor.installJit { [weak self] (success) in
            if success {
                self?.loadJitInfo()
            }
        }
    }
    
    func uninstallJit() {
        
        jitInteractor.uninstallJit { [weak self] (success) in
            if success {
                self?.loadJitInfo()
            }
        }
    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
    }
    
    func saveAppSettings (_ settings: Settings) {
        interactor!.saveAppSettings(settings)
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
    func jiraSettingsDidLoad (_ settings: JiraSettings) {
        
        DispatchQueue.main.sync {
            userInterface!.setJiraSettings(settings)
        }
    }
}
