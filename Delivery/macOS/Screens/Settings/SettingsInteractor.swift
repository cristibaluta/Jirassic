//
//  SettingsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsInteractorInput {
    
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
    
    func getAppSettings() -> Settings {
        
        return localRepository!.settings()
    }
    
    func saveAppSettings (_ settings: Settings) {
        localRepository!.saveSettings(settings)
    }
}
