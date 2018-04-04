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
    func save (emails: String, paths: String)
}

protocol GitPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setButInstall (enabled: Bool)
    func setButEnable (on: Bool?, enabled: Bool?)
    func setPaths (_ paths: String?, enabled: Bool?)
    func setEmails (_ emails: String?, enabled: Bool?)
}

class GitPresenter {
    
    weak var userInterface: GitPresenterOutput?
    fileprivate let gitModule = ModuleGitLogs()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    var isShellScriptInstalled: Bool? {
        didSet {
            self.refresh()
        }
    }
    
    init() {
        
    }
    
    func refresh() {
        
        gitModule.checkIfGitInstalled(completion: { [weak self] commandInstalled in
            
            guard let wself = self, let userInterface = wself.userInterface else {
                return
            }
            if wself.isShellScriptInstalled == true {
                userInterface.setStatusImage(commandInstalled ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
                userInterface.setStatusText(commandInstalled ? "Commits made with Git will appear in Jirassic as tasks." : "Git is not installed")
            } else {
                userInterface.setStatusImage(NSImage.Name.statusUnavailable)
                userInterface.setStatusText("Not possible to use Git, please install shell support first!")
            }
            userInterface.setPaths(wself.localPreferences.string(.settingsGitPaths),
                                   enabled: wself.localPreferences.bool(.enableGit))
            
            userInterface.setEmails(wself.localPreferences.string(.settingsGitAuthors),
                                    enabled: wself.localPreferences.bool(.enableGit))
            
            userInterface.setButEnable(on: wself.localPreferences.bool(.enableGit),
                                       enabled: commandInstalled)
            
            userInterface.setButInstall(enabled: wself.isShellScriptInstalled == false)
        })
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
        panel.message = "Please pick a git project you want to create reports from"
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
    
    private func saveEmails (_ emails: String) {
        localPreferences.set(emails, forKey: .settingsGitAuthors)
    }
    private func savePaths (_ paths: String) {
        localPreferences.set(paths, forKey: .settingsGitPaths)
    }
}
