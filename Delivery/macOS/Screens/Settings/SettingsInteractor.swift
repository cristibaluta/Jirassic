//
//  SettingsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsInteractorInput {
    
    func loadJiraSettings()
    func getAppSettings() -> Settings
    func saveAppSettings (_ settings: Settings)
}

protocol SettingsInteractorOutput {
    
    func jiraSettingsDidLoad (_ settings: JiraSettings)
}

class SettingsInteractor {
    
    var presenter: SettingsInteractorOutput?
    
    init() {
        
    }
}

extension SettingsInteractor: SettingsInteractorInput {
    
    func loadJiraSettings() {
        
//        let settings = JiraSettings(url: lines[0], user: lines[1], separator: lines[2])
//        presenter!.jiraSettingsDidLoad()
    }
    
//    func getJiraPasswordForUser (_ jiraUser: String) {
//        
//        let task = Process()
//        task.launchPath = "/usr/bin/security"
//        task.arguments = ["find-generic-password", "-wa", jiraUser]
//        task.terminationHandler = { task in
//            DispatchQueue.main.async(execute: {
//                print(task)
//            })
//        }
//        task.launch()
//    }
    
    func getAppSettings() -> Settings {
        
        return localRepository!.settings()
    }
    
    func saveAppSettings (_ settings: Settings) {
        localRepository!.saveSettings(settings)
    }
}
