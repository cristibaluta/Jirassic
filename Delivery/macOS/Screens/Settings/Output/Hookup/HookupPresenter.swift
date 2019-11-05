//
//  HookupPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa
import RCPreferences

protocol HookupPresenterInput: class {
    
    var isShellScriptInstalled: Bool? {get set}
    func enableHookup (_ enabled: Bool)
    func enableCredentials (_ enabled: Bool)
    func refresh (withCommand command: String)
    func pickCLI()
}

protocol HookupPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setButEnable (on: Bool?, enabled: Bool?)
    func setButEnableCredentials (on: Bool?, enabled: Bool?)
    func setButPick (enabled: Bool)
    func setCommand (path: String?, enabled: Bool?)
}

class HookupPresenter {
    
    weak var userInterface: HookupPresenterOutput?
    let hookupModule = ModuleHookup()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    var isShellScriptInstalled: Bool? {
        didSet {
            self.refresh()
        }
    }
    
    init() {
        
    }
    
    func refresh() {
        
        hookupModule.isCmdReachable(completion: { [weak self] commandInstalled in
            
            guard let wself = self, let userInterface = wself.userInterface else {
                return
            }
            if wself.isShellScriptInstalled == true {
                userInterface.setStatusImage(commandInstalled ? NSImage.statusAvailableName : NSImage.statusPartiallyAvailableName)
                userInterface.setStatusText(commandInstalled ? "Start/End day actions will be sent to this custom cmd" : "Custom cmd is not reachable")
            } else {
                userInterface.setStatusImage(NSImage.statusUnavailableName)
                userInterface.setStatusText("Not possible to use custom cmd, please install shell support first!")
            }
            userInterface.setCommand(path: wself.localPreferences.string(.settingsHookupCmdName),
                                     enabled: wself.localPreferences.bool(.enableHookup))
            
            userInterface.setButEnable(on: wself.localPreferences.bool(.enableHookup),
                                       enabled: commandInstalled)
            
            userInterface.setButEnableCredentials(on: wself.localPreferences.bool(.enableHookupCredentials),
                                                  enabled: commandInstalled)
            
            userInterface.setButPick(enabled: wself.localPreferences.bool(.enableHookup))
        })
    }
}

extension HookupPresenter: HookupPresenterInput {
    
    func enableHookup (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableHookup)
        userInterface!.setCommand(path: nil, enabled: enabled)
        userInterface!.setButEnable(on: enabled, enabled: nil)
        userInterface!.setButPick(enabled: enabled)
    }
    
    func enableCredentials (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableHookupCredentials)
    }
    
    func refresh (withCommand command: String) {
        // Set the command to userDefaults and it will be read by the hookup module from there
        localPreferences.set(command, forKey: .settingsHookupCmdName)
        refresh()
    }
    
    
    func pickCLI() {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = true
        panel.allowedFileTypes = [""]
        panel.message = "Please select a CLI app"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        panel.begin { [weak self] (result) -> Void in
            
            guard let wself = self else {
                return
            }
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let url = panel.urls.first {
                    var path = url.absoluteString
                    path = path.replacingOccurrences(of: "file://", with: "")
                    
                    wself.refresh (withCommand: path)
                }
            }
        }
    }
}
