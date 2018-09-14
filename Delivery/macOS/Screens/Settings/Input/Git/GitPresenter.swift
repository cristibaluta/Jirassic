//
//  GitPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa

protocol GitPresenterInput: class {
    
    var isShellScriptInstalled: Bool? {get set}
    
    func enableGit (_ enabled: Bool)
    func refresh (withCommand command: String)
    func pickPath()
    func purchase()
    func save (emails: String, paths: String)
}

protocol GitPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setDescriptionText (_ text: String)
    func setButInstall (enabled: Bool)
    func setButPurchase (enabled: Bool)
    func setButEnable (on: Bool?, enabled: Bool?)
    func setPaths (_ paths: String?, enabled: Bool?)
    func setEmails (_ emails: String?, enabled: Bool?)
}

enum GitCellState {
    case needsPurchase
    case needsShellSupport
    case needsGitScript
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
        
        gitModule.checkIfGitInstalled(completion: { [weak self] commandInstalled in
            
            guard let wself = self, let userInterface = wself.userInterface else {
                return
            }
            guard wself.store.isGitPurchased else {
                wself.refresh(state: .needsPurchase)
                return
            }
            guard wself.isShellScriptInstalled == true else {
                wself.refresh(state: .needsShellSupport)
                return
            }
            guard commandInstalled else {
                wself.refresh(state: .needsGitScript)
                return
            }
            
            wself.refresh(state: wself.localPreferences.bool(.enableGit) ? .enabled : .disabled)
            
            userInterface.setPaths(wself.localPreferences.string(.settingsGitPaths),
                                   enabled: wself.localPreferences.bool(.enableGit))
            
            userInterface.setEmails(wself.localPreferences.string(.settingsGitAuthors),
                                    enabled: wself.localPreferences.bool(.enableGit))
        })
    }
    
    private func refresh (state: GitCellState) {
        switch state {
        case .needsPurchase:
            userInterface?.setStatusImage(NSImage.Name.statusUnavailable)
            userInterface?.setStatusText("Purchase git support for 6 months")
            userInterface?.setDescriptionText("This In App Purchase gives you the ability to see commits made with git in  the reports. This is one time purchase and when it expires needs to be purchased again.")
            userInterface?.setButInstall(enabled: false)
            userInterface?.setButPurchase(enabled: true)
            userInterface?.setButEnable(on: false, enabled: false)
            store.getProduct(.git) { skProduct in
                if let product = skProduct {
                    DispatchQueue.main.async {
                        self.userInterface?.setStatusText("Purchase git support for \(product.localizedPrice() ?? "$x") for 6 months")
                    }
                }
            }
        case .needsShellSupport:
            userInterface?.setStatusImage(NSImage.Name.statusUnavailable)
            userInterface?.setStatusText("Not possible to use Git, please install shell support first!")
            userInterface?.setButInstall(enabled: true)
            userInterface?.setButPurchase(enabled: false)
        case .needsGitScript:
            userInterface?.setStatusImage(NSImage.Name.statusPartiallyAvailable)
            userInterface?.setStatusText("Git is not installed.")
            userInterface?.setButInstall(enabled: true)
            userInterface?.setButPurchase(enabled: false)
        case .disabled:
            userInterface?.setButEnable(on: false, enabled: true)
        case .enabled:
            userInterface?.setButEnable(on: true, enabled: true)
        }
    }
}

extension GitPresenter: GitPresenterInput {
    
    func enableGit (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableGit)
        userInterface?.setPaths(nil, enabled: enabled)
        userInterface?.setEmails(nil, enabled: enabled)
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
        panel.message = "Select the root of the git project you want to create reports from"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        panel.begin { [weak self] (result) -> Void in
            
            guard let wself = self, let userInterface = wself.userInterface else {
                return
            }
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let url = panel.urls.first {
                    var path = url.absoluteString
                    path = path.replacingOccurrences(of: "file://", with: "")
                    path.removeLast()
                    // TODO: Validate if the picked project is a git project
                    
                    let existingPaths = wself.localPreferences.string(.settingsGitPaths)
                    let updatedPaths = existingPaths == "" ? path : (existingPaths + "," + path)
                    wself.savePaths(updatedPaths)
                    userInterface.setPaths(updatedPaths, enabled: wself.localPreferences.bool(.enableGit))
                }
            }
        }
    }
    
    func save (emails: String, paths: String) {
        saveEmails(emails)
        savePaths(paths)
    }
    
    func purchase() {
        store.purchase(product: .git) { [weak self] (success) in
            if success {
                self?.refresh(state: self?.localPreferences.bool(.enableGit) == true ? .enabled : .disabled)
            }
        }
    }
    
    private func saveEmails (_ emails: String) {
        localPreferences.set(emails, forKey: .settingsGitAuthors)
    }
    private func savePaths (_ paths: String) {
        localPreferences.set(paths, forKey: .settingsGitPaths)
    }
}
