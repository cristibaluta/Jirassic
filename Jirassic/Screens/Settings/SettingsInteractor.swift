//
//  SettingsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

struct JiraSettings {
    var url: String?
    var user: String?
    var separator: String?
}

protocol SettingsInteractorInput {
    
    func getJiraSettings() -> JiraSettings?
    func getJiraPasswordForUser (_ jiraUser: String)
    func getAppSettings() -> Settings
    func saveAppSettings (_ settings: Settings)
}

protocol SettingsInteractorOutput {
    
}

class SettingsInteractor {
    
    var settingsPresenter: SettingsInteractorOutput?
    
    init() {
        
    }
}

extension SettingsInteractor: SettingsInteractorInput {
    
    func getJiraSettings() -> JiraSettings? {
        
        let homeDirectory = NSHomeDirectory()
        let jitconfigPath = "\(homeDirectory)/.jitconfig"
        
        if FileManager.default.fileExists(atPath: jitconfigPath) {
            do {
                let jitconfig = try NSString(contentsOfFile: jitconfigPath, encoding: String.Encoding.utf8.rawValue)
                let lines = jitconfig.components(separatedBy: "\n") as [String]
                let settings = JiraSettings(url: lines[0], user: lines[1], separator: lines[2])
                return settings
            }
            catch {}
        }
        return nil
    }
    
    func getJiraPasswordForUser (_ jiraUser: String) {
        
        let task = Process()
        task.launchPath = "/usr/bin/security"
        task.arguments = ["find-generic-password", "-wa", jiraUser]
        task.terminationHandler = { task in
            DispatchQueue.main.async(execute: {
                print(task)
            })
        }
        task.launch()
    }
    
    func getAppSettings() -> Settings {
        
        return localRepository!.settings()
    }
    
    func saveAppSettings (_ settings: Settings) {
        localRepository!.saveSettings(settings)
    }
}
