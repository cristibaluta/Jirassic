//
//  SettingsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import ServiceManagement
import RCPreferences
import RCLog

protocol SettingsInteractorInput: AnyObject {
    
    func getAppSettings() -> Settings
    func saveAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

protocol SettingsInteractorOutput: AnyObject {
    
}

class SettingsInteractor {
    
    weak var presenter: SettingsInteractorOutput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    init() {
        
    }
}

extension SettingsInteractor: SettingsInteractorInput {
    
    func getAppSettings() -> Settings {
        return localRepository!.settings()
    }
    
    func saveAppSettings (_ settings: Settings) {
        RCLog("Saving \(settings)")
        localRepository!.saveSettings(settings)
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        let launchAtStartup = SMLoginItemSetEnabled(launcherIdentifier as CFString, enabled)
        localPreferences.set(launchAtStartup ? enabled : false, forKey: .launchAtStartup)
    }
}
