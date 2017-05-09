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
//    func installTools()
//    func uninstallTools()
    func showSettings()
    func saveAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

protocol SettingsPresenterOutput: class {
    
    func setJitIsInstalled (_ installed: Bool)
    func showAppSettings (_ settings: Settings)
    func enabledLaunchAtStartup (_ enabled: Bool)
}

class SettingsPresenter {
    
    fileprivate var extensionsInstaller = ExtensionsInteractor()
    weak var userInterface: SettingsPresenterOutput?
    var interactor: SettingsInteractorInput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
}

extension SettingsPresenter: SettingsPresenterInput {
    
    func loadJitInfo() {
        
        extensionsInstaller.checkTools { (installed, compatible) in
            
            self.userInterface!.setJitIsInstalled( installed )
        }
    }
    
//    func installTools() {
//        
//        extensionsInstaller.installTools { [weak self] (success) in
//            if success {
//                self?.loadJitInfo()
//            }
//        }
//    }
//    
//    func uninstallTools() {
//        
//        extensionsInstaller.uninstallTools { [weak self] (success) in
//            if success {
//                self?.loadJitInfo()
//            }
//        }
//    }
    
    func showSettings() {
        let settings = interactor!.getAppSettings()
        userInterface!.showAppSettings(settings)
        userInterface!.enabledLaunchAtStartup( localPreferences.bool(.launchAtStartup) )
    }
    
    func saveAppSettings (_ settings: Settings) {
        interactor!.saveAppSettings(settings)
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        interactor!.enabledLaunchAtStartup(enabled)
    }
}

extension SettingsPresenter: SettingsInteractorOutput {
    
}
