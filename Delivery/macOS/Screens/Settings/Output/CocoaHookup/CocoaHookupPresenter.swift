//
//  CocoaHookupPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa
import RCPreferences

protocol CocoaHookupPresenterInput: class {
    
    var isShellScriptInstalled: Bool? {get set}
    func enableCocoaHookup (_ enabled: Bool)
    func refresh (withApp appName: String)
    func pickApp()
}

protocol CocoaHookupPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setButEnable (on: Bool?, enabled: Bool?)
    func setButPick (enabled: Bool)
    func setApp (appName: String?, enabled: Bool?)
}

class CocoaHookupPresenter {
    
    weak var userInterface: CocoaHookupPresenterOutput?
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
        
        hookupModule.isAppReachable(completion: { [weak self] appInstalled in
            
            guard let wself = self, let userInterface = wself.userInterface else {
                return
            }
            if wself.isShellScriptInstalled == true {
                userInterface.setStatusImage(appInstalled ? NSImage.statusAvailableName : NSImage.statusPartiallyAvailableName)
                userInterface.setStatusText(appInstalled ? "Start/Stop AppleScripts will be sent to the selected Cocoa app" : "App not reachable")
            } else {
                userInterface.setStatusImage(NSImage.statusUnavailableName)
                userInterface.setStatusText("Not possible to use hookups, please install shell support first!")
            }
            userInterface.setApp(appName: wself.localPreferences.string(.settingsHookupAppName),
                                 enabled: wself.localPreferences.bool(.enableCocoaHookup))
            
            userInterface.setButEnable(on: wself.localPreferences.bool(.enableCocoaHookup),
                                       enabled: appInstalled)
            
            userInterface.setButPick(enabled: wself.localPreferences.bool(.enableCocoaHookup))
        })
    }
}

extension CocoaHookupPresenter: CocoaHookupPresenterInput {
    
    func enableCocoaHookup (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableCocoaHookup)
        userInterface!.setApp(appName: nil, enabled: enabled)
        userInterface!.setButEnable(on: enabled, enabled: nil)
        userInterface!.setButPick(enabled: enabled)
    }
    
    func refresh (withApp appName: String) {
        // Set the command to userDefaults and it will be read by the hookup module from there
        localPreferences.set(appName, forKey: .settingsHookupAppName)
        refresh()
    }
    
    
    func pickApp() {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = false
        panel.allowedFileTypes = ["app"]
        panel.message = "Please select the custom .app with support for Jirassic AppleScript"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        panel.begin { [weak self] (result) -> Void in
            
            guard let self else {
                return
            }
            if result == NSApplication.ModalResponse.OK {
                if let url = panel.urls.first {
                    let appName = url.absoluteString
                        .components(separatedBy: "/")
                        .last?
                        .replacingOccurrences(of: ".app", with: "")
                        .replacingOccurrences(of: "%20", with: " ")
                    self.refresh (withApp: appName ?? "")
                }
            }
        }
    }
}
