//
//  HookupPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa

protocol HookupPresenterInput: class {
    var isShellScriptInstalled: Bool? {get set}
    func enableHookup (_ enabled: Bool)
    func enableCredentials (_ enabled: Bool)
    func refresh (withCommand command: String)
}

protocol HookupPresenterOutput: class {
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setButEnable (on: Bool?, enabled: Bool?)
    func setButEnableCredentials (on: Bool?, enabled: Bool?)
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
        
        hookupModule.isHookupInstalled(completion: { [weak self] commandInstalled in
            
            guard let wself = self else {
                return
            }
            if wself.isShellScriptInstalled == true {
                wself.userInterface?.setStatusImage(commandInstalled ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
                wself.userInterface?.setStatusText(commandInstalled ? "Start/End day actions will be sent to this custom cmd" : "Custom cmd is not reachable")
            } else {
                wself.userInterface?.setStatusImage(NSImage.Name.statusUnavailable)
                wself.userInterface?.setStatusText("Not possible to use custom cmd, please install shell support first!")
            }
            wself.userInterface?.setCommand(path: wself.localPreferences.string(.settingsHookupCmdName),
                                            enabled: wself.localPreferences.bool(.enableHookup))
            
            wself.userInterface?.setButEnable(on: wself.localPreferences.bool(.enableHookup),
                                              enabled: commandInstalled)
            
            wself.userInterface?.setButEnableCredentials(on: wself.localPreferences.bool(.enableHookupCredentials),
                                                         enabled: commandInstalled)
        })
    }
}

extension HookupPresenter: HookupPresenterInput {
    
    func enableHookup (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableHookup)
        userInterface?.setCommand(path: nil, enabled: enabled)
        userInterface?.setButEnable(on: enabled, enabled: nil)
    }
    
    func enableCredentials (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableHookupCredentials)
    }
    
    func refresh (withCommand command: String) {
        // Set the command to userDefaults and it will be read by the hokup module from there
        localPreferences.set(command, forKey: .settingsHookupCmdName)
        refresh()
    }
}
