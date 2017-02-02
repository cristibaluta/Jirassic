//
//  SettingsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol SettingsPresenterInput: class {
    
    func loadJitInfo()
    func installJit()
    func uninstallJit()
    func showSettings()
    func saveAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

protocol SettingsPresenterOutput: class {
    
    func setJitIsInstalled (_ installed: Bool)
    func setJiraSettings (_ settings: JiraSettings)
    func showAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

class SettingsPresenter {
    
    fileprivate var jitInstaller = JitInstaller()
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func loadJitInfo() {
        
        jitInstaller.isInstalled { installed in
            
            DispatchQueue.main.sync {
                self.userInterface!.setJitIsInstalled( installed )
            }
            if installed {
                self.jitInstaller.getJiraSettings { dict in
                    let settings = JiraSettings(url: dict["url"],
                                                user: dict["user"],
                                                separator: dict["separator"])
                    self.jiraSettingsDidLoad(settings)
                }
            } else {
                self.jiraSettingsDidLoad(JiraSettings())
            }
        }
    }
    
    func installJit() {
        
        jitInstaller.installJit { [weak self] (success) in
            if success {
                self?.loadJitInfo()
            }
        }
    }
    
    func uninstallJit() {
        
        jitInstaller.uninstallJit { [weak self] (success) in
            if success {
                self?.loadJitInfo()
            }
        }
    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
        userInterface!.enabledLaunchAtStartup( InternalSettings().launchAtStartup )
    }
    
    func saveAppSettings (_ settings: Settings) {
        interactor!.saveAppSettings(settings)
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        interactor!.enabledLaunchAtStartup(enabled)
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
    func jiraSettingsDidLoad (_ settings: JiraSettings) {
        
        DispatchQueue.main.sync {
            userInterface!.setJiraSettings(settings)
        }
    }
}
