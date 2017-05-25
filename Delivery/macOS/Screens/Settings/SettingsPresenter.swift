//
//  SettingsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsPresenterInput: class {
    
    func checkExtensions()
    func showSettings()
    func saveAppSettings (_ settings: Settings)
    func enabledBackup (_ enabled: Bool)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

protocol SettingsPresenterOutput: class {
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool)
    func setJitStatus (compatible: Bool, scriptInstalled: Bool)
    func setCodeReviewStatus (compatible: Bool, scriptInstalled: Bool)
    func showAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
    func enabledBackup (_ enabled: Bool, title: String)
}

class SettingsPresenter {
    
    fileprivate var extensions = ExtensionsInteractor()
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func checkExtensions() {
        
        extensions.getVersions { (versions) in
            
            let compatibility = Versioning.isCompatible(versions)
            self.userInterface!.setJirassicStatus(compatible: compatibility.jirassicCmd, 
                                                  scriptInstalled: versions.shellScript != "" )
            self.userInterface!.setJitStatus(compatible: compatibility.jitCmd, 
                                             scriptInstalled: versions.shellScript != "" )
            self.userInterface!.setCodeReviewStatus(compatible: compatibility.browserScript, 
                                                    scriptInstalled: versions.browserScript != "" )
        }
    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
        userInterface!.enabledLaunchAtStartup( localPreferences.bool(.launchAtStartup) )
        enabledBackup(settings.enableBackup)
    }
    
    func saveAppSettings (_ settings: Settings) {
        interactor!.saveAppSettings(settings)
    }
    
    func enabledBackup (_ enabled: Bool) {
        #if APPSTORE
        if enabled {
            remoteRepository = CloudKitRepository()
            remoteRepository?.getUser({ (user) in
                if user == nil {
                    self.userInterface?.enabledBackup(false, title: "Backup to iCloud (You are not logged in)")
                    remoteRepository = nil
                } else {
                    self.userInterface?.enabledBackup(true, title: "Backup to iCloud")
                }
            })
        } else {
            remoteRepository = nil
            self.userInterface?.enabledBackup(enabled, title: "Backup to iCloud")
        }
        #endif
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        interactor!.enabledLaunchAtStartup(enabled)
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
}
