//
//  SettingsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsInteractorInput {
    
    
}

protocol SettingsInteractorOutput {
    
    
}

class SettingsInteractor {
    
    var settingsPresenter: SettingsInteractorOutput?
    
    init() {
        
    }
}

extension SettingsInteractor: SettingsInteractorInput {
    
    func getJiraPasswordForUser (jiraUser: String) {
        
        let task = NSTask()
        task.launchPath = "/usr/bin/security"
        task.arguments = ["find-generic-password", "-wa", jiraUser]
        task.terminationHandler = { task in
            dispatch_async(dispatch_get_main_queue(), {
                print(task)
            })
        }
        task.launch()
    }
}