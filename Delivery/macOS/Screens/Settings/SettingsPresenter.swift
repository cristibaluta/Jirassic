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
    
    func setShellStatus (available: Bool, compatible: Bool)
    func setJirassicStatus (available: Bool, compatible: Bool)
    func setJitStatus (available: Bool, compatible: Bool)
    func setGitStatus (available: Bool)
    func setBrowserStatus (available: Bool, compatible: Bool)
    func setHookupStatus (available: Bool)
    func showAppSettings (_ settings: Settings)
    func enableBackup (_ enabled: Bool, title: String)
    func enableLaunchAtStartup (_ enabled: Bool)
    func selectTab (_ tab: SettingsTab)
}

class SettingsPresenter {
    
    fileprivate var extensions = ExtensionsInteractor()
    #if !APPSTORE
    fileprivate var extensionsInstaller = ExtensionsInstallerInteractor()
    #endif
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func checkExtensions() {
        
        extensions.getVersions { [weak self] (versions) in
            
            guard let userInterface = self?.userInterface else {
                return
            }
            let compatibility = Versioning.compatibilityMap(versions)

            // Setup shell script
            userInterface.setShellStatus(available: versions.shellScript != "",
                                         compatible: compatibility.shellScript)

            // Setup jirassic cmd
            userInterface.setJirassicStatus(available: versions.jirassicCmd != "",
                                            compatible: compatibility.jirassicCmd)

            // Setup jit cmd
            userInterface.setJitStatus(available: versions.shellScript != "",
                                       compatible: compatibility.jitCmd)

            // Setup browser script
            userInterface.setBrowserStatus(available: versions.browserScript != "",
                                           compatible: compatibility.browserScript)
            
            // Git requires extra call
            userInterface.setGitStatus(available: versions.shellScript != "")
            
            // Hookup requires extra call
            userInterface.setHookupStatus(available: versions.shellScript != "")
        }
    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
        userInterface!.enableLaunchAtStartup( localPreferences.bool(.launchAtStartup) )
        enableBackup(settings.enableBackup)
        let lastActiveSettingsTab = SettingsTab(rawValue: localPreferences.int(.settingsActiveTab))!
        selectTab(lastActiveSettingsTab)
    }
    
    func selectTab (_ tab: SettingsTab) {
        localPreferences.set(tab.rawValue, forKey: .settingsActiveTab)
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
            self.userInterface!.setJirassicStatus(available: success, compatible: true)
        }
        #endif
    }
    
    func installJit() {
        #if !APPSTORE
        extensionsInstaller.installJit { (success) in
            self.userInterface!.setJitStatus(available: success, compatible: true)
        }
        #endif
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
}
