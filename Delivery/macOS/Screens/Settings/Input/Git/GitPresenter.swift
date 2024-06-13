//
//  GitPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa
import RCPreferences

protocol GitPresenterInput: class {
    
    var isShellScriptInstalled: Bool? {get set}
    
    func enableGit (_ enabled: Bool)
    func refresh (withCommand command: String)
}

protocol GitPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setDescriptionText (_ text: String)
    func setButInstall (enabled: Bool)
    func setButPurchase (enabled: Bool)
    func setButEnable (on: Bool?, enabled: Bool?)
}

enum GitCellState {
    // First thing to do is purchase it
    case needsPurchase
    // After purchasing you need to install the apple scripts
    case needsShellScript
    case needsGitScript
    // When purchased and reachable via shell you have the option to enable or disable
    case disabled
    case enabled
}

class GitPresenter {
    
    weak var userInterface: GitPresenterOutput?
    private let gitModule = ModuleGitLogs()
    private let localPreferences = RCPreferences<LocalPreferences>()
    private let store = Store.shared
    
    var isShellScriptInstalled: Bool? {
        didSet {
            refresh()
        }
    }
    
    init() {
        
    }
    
    private func refresh() {
        
        guard store.isGitPurchased else {
            refresh(state: .needsPurchase)
            return
        }
        gitModule.checkIfGitInstalled(completion: { [weak self] commandInstalled in
            
            guard let wself = self else {
                return
            }
            guard wself.isShellScriptInstalled == true else {
                wself.refresh(state: .needsShellScript)
                return
            }
            guard commandInstalled else {
                wself.refresh(state: .needsGitScript)
                return
            }
            
            wself.refresh(state: wself.localPreferences.bool(.enableGit) ? .enabled : .disabled)
        })
    }
    
    private func refresh (state: GitCellState) {
        guard let userInterface = self.userInterface else {
            return
        }
        userInterface.setDescriptionText("You will see git commits right in the reports. They are saved to database and synced with iCloud only after closing the day. Note: Git commits are not always 100% reliable")
        switch state {
        case .needsPurchase:
            userInterface.setStatusImage(NSImage.statusUnavailableName)
            userInterface.setStatusText("Purchase Git support")
            userInterface.setButInstall(enabled: false)
            userInterface.setButPurchase(enabled: true)
            userInterface.setButEnable(on: false, enabled: false)
        case .needsShellScript:
            userInterface.setStatusImage(NSImage.statusUnavailableName)
            userInterface.setStatusText("Not possible to use Git, please install shell scripts first!")
            userInterface.setButInstall(enabled: true)
            userInterface.setButPurchase(enabled: false)
        case .needsGitScript:
            userInterface.setStatusImage(NSImage.statusPartiallyAvailableName)
            userInterface.setStatusText("Git plugin is not installed, please install.")
            userInterface.setButInstall(enabled: true)
            userInterface.setButPurchase(enabled: false)
        case .disabled:
            userInterface.setStatusText("Git plugin is installed and ready to use, please enable.")
            userInterface.setButEnable(on: false, enabled: true)
            userInterface.setButInstall(enabled: false)
            userInterface.setButPurchase(enabled: false)
        case .enabled:
            userInterface.setStatusText("Git plugin is installed and ready to use.")
            userInterface.setButEnable(on: true, enabled: true)
            userInterface.setButInstall(enabled: false)
            userInterface.setButPurchase(enabled: false)
        }
    }
}

extension GitPresenter: GitPresenterInput {
    
    func enableGit (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableGit)
        userInterface?.setButEnable(on: enabled, enabled: nil)
    }
    
    func refresh (withCommand command: String) {
        // Set the command to userDefaults and it will be read by the hokup module from there
//        localPreferences.set(command, forKey: .settingsHookupCmdName)
        refresh()
    }

    func pickPath() {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select the root of the git project you want to track"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        panel.begin { [weak self] (result) -> Void in
            
            guard let self, let userInterface = self.userInterface else {
                return
            }
            if result == NSApplication.ModalResponse.OK {
                if let url = panel.urls.first {
                    var path = url.absoluteString
                    path = path.replacingOccurrences(of: "file://", with: "")
                    path.removeLast()
                    // TODO: Validate if the picked project is a git project
                    
                    let existingPaths = self.localPreferences.string(.settingsGitPaths)
                    let updatedPaths = existingPaths == "" ? path : (existingPaths + "," + path)
                    self.savePaths(updatedPaths)
                    userInterface.setPaths(updatedPaths, enabled: self.localPreferences.bool(.enableGit))
                }
            }
        }
    }
    
}
