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
    func testJit()
    func installJit()
    func uninstallJit()
    var jitInstalled: Bool {get}
}

protocol SettingsPresenterOutput {
    
    func showLoadingIndicator (show: Bool)
    func setJitIsInstalled (installed: Bool)
}

class SettingsPresenter {
    
    private var jitInteractor = JitInteractor()
    var jitInstalled: Bool {
        get {
            return self.jitInteractor.isInstalled
        }
    }
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
    
    func testJit() {
        
        userInterface!.setJitIsInstalled( jitInteractor.isInstalled )
        
//        let keychain = KeychainWrapper.defaultKeychainWrapper()
//        keychain.setString("aaa", forKey: "cbaluta2")
//        print(keychain.stringForKey("cbaluta2"))
        
        let task = NSTask()
        task.launchPath = "/usr/bin/security"
        task.arguments = ["find-generic-password", "-wa", "cbaluta"]
        task.terminationHandler = { task in
            dispatch_async(dispatch_get_main_queue(), {
                print(task)
            })
        }
        task.launch()
    }
    
    func installJit() {
        
        jitInteractor.installJit { [weak self] (success) in
            if success {
                self?.testJit()
            }
        }
    }
    
    func uninstallJit() {
        
        jitInteractor.uninstallJit { [weak self] (success) in
            if success {
                self?.testJit()
            }
        }
    }
}
