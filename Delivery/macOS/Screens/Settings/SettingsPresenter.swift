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
    func selectTab (_ tab: SettingsTab)
    func saveAppSettings (_ settings: Settings)
    func enableBackup (_ enabled: Bool)
    func enableLaunchAtStartup (_ enabled: Bool)
    func installJirassic()
    func installJit()
}

protocol SettingsPresenterOutput: class {
    
    func setShellStatus (compatibility: Compatibility)
    func setJirassicStatus (compatibility: Compatibility)
    func setJitStatus (compatibility: Compatibility)
    func setGitStatus (available: Bool)
    func setBrowserStatus (compatibility: Compatibility)
    func setHookupStatus (available: Bool)
    func showAppSettings (_ settings: Settings)
    func enableBackup (_ enabled: Bool, title: String)
    func enableLaunchAtStartup (_ enabled: Bool)
    func selectTab (_ tab: SettingsTab)
}

class SettingsPresenter {
    
    private var extensions = ExtensionsInteractor()
    #if !APPSTORE
    private var extensionsInstaller = ExtensionsInstallerInteractor()
    #endif
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
    private let pref = RCPreferences<LocalPreferences>()
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func checkExtensions() {
        
        extensions.getVersions { [weak self] (versions) in
            
            guard let userInterface = self?.userInterface else {
                return
            }
            let compatibility = Versioning(versions: versions)

            // Setup shell script
            userInterface.setShellStatus(compatibility: compatibility.shellScript)

            // Setup jirassic cmd
            userInterface.setJirassicStatus(compatibility: compatibility.jirassic)

            // Setup jit cmd
            userInterface.setJitStatus(compatibility: compatibility.jit)

            // Setup browser script
            userInterface.setBrowserStatus(compatibility: compatibility.browser)
            
            // Git requires extra call
            userInterface.setGitStatus(available: versions.shellScript != "")
            
            // Hookup requires extra call
            userInterface.setHookupStatus(available: versions.shellScript != "")
        }
    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
        userInterface!.enableLaunchAtStartup( pref.bool(.launchAtStartup) )
        enableBackup(settings.enableBackup)
        let lastActiveSettingsTab = SettingsTab(rawValue: pref.int(.settingsActiveTab))!
        selectTab(lastActiveSettingsTab)
    }
    
    func selectTab (_ tab: SettingsTab) {
        pref.set(tab.rawValue, forKey: .settingsActiveTab)
        userInterface!.selectTab(tab)
    }
    
    func saveAppSettings (_ settings: Settings) {
        interactor!.saveAppSettings(settings)
    }
    
    func enableBackup (_ enabled: Bool) {
        #if APPSTORE
        if enabled {
            // Init the global instance of remoteRepository in AppDelegate
            remoteRepository = CloudKitRepository()
            remoteRepository?.getUser({ (user) in
                if user == nil {
                    self.userInterface?.enableBackup(false, title: "Syncing with iCloud not possible, you are not logged into iCloud")
                    remoteRepository = nil
                } else {
                    self.userInterface?.enableBackup(true, title: "Sync with iCloud and iOS app")
                }
            })
        } else {
            remoteRepository = nil
            self.userInterface?.enableBackup(enabled, title: "Sync with iCloud and iOS app")
        }
        #endif
    }
    
    func enableLaunchAtStartup (_ enabled: Bool) {
        interactor!.enabledLaunchAtStartup(enabled)
    }
    
    func installJirassic() {
        #if !APPSTORE
        extensionsInstaller.installJirassic { (success) in
            #warning("Update the compatibility object")
//            self.userInterface!.setJirassicStatus(compatibility: <#T##Compatibility#>)
        }
        #endif
    }
    
    func installJit() {
        #if !APPSTORE
        extensionsInstaller.installJit { (success) in
            #warning("Update the compatibility object")
//            self.userInterface!.setJitStatus(compatibility: <#T##Compatibility#>)
        }
        #endif
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
}
