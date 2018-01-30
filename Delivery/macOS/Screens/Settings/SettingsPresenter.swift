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
    func installJirassic()
    func installJit()
    func showJiraProjects()
}

protocol SettingsPresenterOutput: class {
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool)
    func setJitStatus (compatible: Bool, scriptInstalled: Bool)
    func setCodeReviewStatus (compatible: Bool, scriptInstalled: Bool)
    func showAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
    func enabledBackup (_ enabled: Bool, title: String)
    func selectTab (atIndex index: Int)
    func enabledJiraProgressIndicator (_ enabled: Bool)
}

class SettingsPresenter {
    
    fileprivate var extensions = ExtensionsInteractor()
    #if !APPSTORE
    fileprivate var extensionsInstaller = ExtensionsInstallerInteractor()
    #endif
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
    var jiraTempoInteractor = ModuleJiraTempo()
    var hookup = ModuleHookup()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func checkExtensions() {
        
        extensions.getVersions { [weak self] (versions) in
            
            guard let userInterface = self?.userInterface else {
                return
            }
            let compatibility = Versioning.isCompatible(versions)
            userInterface.setJirassicStatus(compatible: compatibility.jirassicCmd, 
                                            scriptInstalled: versions.shellScript != "" )
            userInterface.setJitStatus(compatible: compatibility.jitCmd, 
                                       scriptInstalled: versions.shellScript != "" )
            userInterface.setCodeReviewStatus(compatible: compatibility.browserScript, 
                                              scriptInstalled: versions.browserScript != "" )
        }
    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
        userInterface!.enabledLaunchAtStartup( localPreferences.bool(.launchAtStartup) )
        enabledBackup(settings.enableBackup)
        userInterface!.selectTab(atIndex: localPreferences.int(.settingsActiveTab))
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
    
    func installJirassic() {
        #if !APPSTORE
        extensionsInstaller.installJirassic { (success) in
            self.userInterface!.setJirassicStatus(compatible: true, scriptInstalled: success)
        }
        #endif
    }
    
    func installJit() {
        #if !APPSTORE
        extensionsInstaller.installJit { (success) in
            self.userInterface!.setJitStatus(compatible: true, scriptInstalled: success)
        }
        #endif
    }
    
    func showJiraProjects() {
        userInterface?.enabledJiraProgressIndicator(true)
        jiraTempoInteractor.fetchProjects { [weak self] (projects) in
            RCLog(projects)
            self?.userInterface?.enabledJiraProgressIndicator(false)
        }
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
}
