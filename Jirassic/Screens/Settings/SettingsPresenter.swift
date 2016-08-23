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
    
    func testJit() {
        
        let asc = NSAppleScript(source: "sudo /usr/local/bin/jit")
        let res = asc?.executeAndReturnError(nil)
        print (res)
        
//        let task = NSTask()
//        task.launchPath = "/usr/local/bin/jit"
//        task.arguments = []
//        task.terminationHandler = { task in
//            dispatch_async(dispatch_get_main_queue(), {
////                print(task)
//            })
//        }
//        task.launch()
//        task.waitUntilExit()
    }
    
    func installJit() {
        testJit()
        return
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource("jit", ofType: nil)
        task.arguments = ["install"]
        task.terminationHandler = { task in
            dispatch_async(dispatch_get_main_queue(), {
                //                print(task)
            })
        }
        task.launch()
    }
}
