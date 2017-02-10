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
    func installTools()
    func uninstallTools()
    func showSettings()
    func saveAppSettings (_ settings: Settings)
    func saveJiraSettings (_ settings: JiraSettings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

protocol SettingsPresenterOutput: class {
    
    func setJitIsInstalled (_ installed: Bool)
    func setJiraSettings (_ settings: JiraSettings)
    func showAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

class SettingsPresenter {
    
    fileprivate var scriptsInstaller = AppleScriptsInteractor()
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func loadJitInfo() {
        
        scriptsInstaller.isInstalled { installed in
            
            self.userInterface!.setJitIsInstalled( installed )
            if installed {
                self.scriptsInstaller.getJiraSettings { dict in
                    let settings = JiraSettings(url: dict["url"],
                                                user: dict["user"],
                                                password: nil,
                                                separator: dict["separator"])
                    self.jiraSettingsDidLoad(settings)
                }
            } else {
                self.jiraSettingsDidLoad(JiraSettings())
            }
        }
    }
    
    func installTools() {
        
        scriptsInstaller.installTools { [weak self] (success) in
            if success {
                self?.loadJitInfo()
            }
        }
    }
    
    func uninstallTools() {
        
        scriptsInstaller.uninstallTools { [weak self] (success) in
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
    
    func saveJiraSettings (_ settings: JiraSettings) {
        RCLogO(settings)
        scriptsInstaller.isInstalled { installed in
            
//            self.userInterface!.setJitIsInstalled( installed )
            if installed {
                self.scriptsInstaller.saveJiraSettings(settings, completion: { success in
                    
                })
            }
        }
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        interactor!.enabledLaunchAtStartup(enabled)
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
    func jiraSettingsDidLoad (_ settings: JiraSettings) {
        userInterface!.setJiraSettings(settings)
    }
}
