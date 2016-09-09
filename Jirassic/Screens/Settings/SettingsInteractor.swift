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
    func getJiraPasswordForUser (jiraUser: String)
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
        
        if NSFileManager.defaultManager().fileExistsAtPath(jitconfigPath) {
            do {
                let jitconfig = try NSString(contentsOfFile: jitconfigPath, encoding: NSUTF8StringEncoding)
                let lines = jitconfig.componentsSeparatedByString("\n") as [String]
                let settings = JiraSettings(url: lines[0], user: lines[1], separator: lines[2])
                return settings
            }
            catch {}
        }
        return nil
    }
    
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