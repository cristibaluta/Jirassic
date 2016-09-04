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
    
    private let jitInstallationPath = "/usr/local/bin/"
    var jitInstalled = false
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
        
        let asc = NSAppleScript(source: "do shell script \"\(jitInstallationPath)jit\"")
        if let response = asc?.executeAndReturnError(nil) {
            print(response)
            jitInstalled = true
        } else {
            print("Could not find Jit at \(jitInstallationPath)")
            jitInstalled = false
        }
        userInterface!.setJitIsInstalled(jitInstalled)
        
//        let task = NSTask()
//        task.launchPath = "\(jitInstallationPath)jit2"
////        task.arguments = [""]
//        task.terminationHandler = { task in
//            dispatch_async(dispatch_get_main_queue(), {
//                print(task)
//                print(task.terminationStatus)
//            })
//        }
//        try task.launch()
    }
    
    func installJit() {
        
        guard let bundledJitPath = NSBundle.mainBundle().pathForResource("jit", ofType: nil) else {
            return
        }
        let asc = NSAppleScript(source: "do shell script \"sudo cp \(bundledJitPath) \(jitInstallationPath)\" with administrator privileges")
        if let response = asc?.executeAndReturnError(nil) {
            print(response)
            testJit()
        } else {
            print("Could not copy Jit from \(bundledJitPath) to \(jitInstallationPath)")
        }
    }
    
    func uninstallJit() {
        
        let asc = NSAppleScript(source: "do shell script \"sudo rm \(jitInstallationPath)jit\" with administrator privileges")
        if let response = asc?.executeAndReturnError(nil) {
            print(response)
            testJit()
        } else {
            print("Could not delete Jit from \(jitInstallationPath)")
        }
    }
}
