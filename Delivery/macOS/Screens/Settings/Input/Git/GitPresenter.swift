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
    let gitModule = ModuleGitLogs()
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
            
            guard let wself = self else {
                return
            }
            if wself.isShellScriptInstalled == true {
                wself.userInterface?.setStatusImage(commandInstalled ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
                wself.userInterface?.setStatusText(commandInstalled ? "Commits made with Git will appear in Jirassic as tasks." : "Git is not installed")
            } else {
                wself.userInterface?.setStatusImage(NSImage.Name.statusUnavailable)
                wself.userInterface?.setStatusText("Not possible to use Git, please install shell support first!")
            }
            wself.userInterface?.setPaths(wself.localPreferences.string(.settingsGitPaths),
                                          enabled: wself.localPreferences.bool(.enableGit))
            
            wself.userInterface?.setEmails(wself.localPreferences.string(.settingsGitAuthors),
                                           enabled: wself.localPreferences.bool(.enableGit))
            
            wself.userInterface?.setButEnable(on: wself.localPreferences.bool(.enableGit),
                                              enabled: commandInstalled)
            wself.userInterface?.setButInstall(enabled: wself.isShellScriptInstalled == false)
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
}
