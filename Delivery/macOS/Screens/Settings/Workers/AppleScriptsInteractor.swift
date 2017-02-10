//
//  CMDToolsInstaller.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import Cocoa

class AppleScriptsInteractor {
    
    fileprivate let localBinPath = "/usr/local/bin/"
    fileprivate let scripts: AppleScriptInstallerProtocol = SandboxedAppleScriptInstaller()
    fileprivate let manager = FileManager.default
    
    func getJiraSettings (completion: @escaping ([String: String]) -> Void) {
        
        scripts.getVersion(completion: { dict in
            completion(dict)
        })
    }
    
    func saveJiraSettings (_ settings: JiraSettings, completion: @escaping ([String: String]) -> Void) {
        
        scripts.getVersion(completion: { dict in
            completion(dict)
        })
    }
    
    func getSafariUrl (completion: @escaping (String) -> Void) {
        scripts.getSafariUrl(completion: completion)
    }
    
    func isInstalled (completion: @escaping (Bool) -> Void) {
        
        guard isScriptInstalled() else {
            completion(false)
            return
        }
        scripts.getVersion(completion: { dict in
            let isInstalled = dict["version"] != nil
            completion(isInstalled)
        })
    }
    
    func installTools (_ completion: @escaping (Bool) -> Void) {
        
        if isScriptInstalled() {
            installCmds(completion)
        } else {
            installScriptAndCmds(completion)
        }
    }
    
    func uninstallTools (_ completion: @escaping (Bool) -> Void) {
        
        if isScriptInstalled() {
            uninstallCmds({ success in
                if success {
                    let scriptsDirectory = self.scripts.scriptsDirectory!
                    let scriptUrl = scriptsDirectory.appendingPathComponent("CommandLineTools.scpt")
                    self.uninstallScript(atUrl: scriptUrl, completion)
                } else {
                    completion(false)
                }
            })
        } else {
            completion(false)
        }
    }
}

extension AppleScriptsInteractor {
    
    fileprivate func isScriptInstalled() -> Bool {
        let scriptsDirectory = scripts.scriptsDirectory!
        return manager.fileExists(atPath: scriptsDirectory.appendingPathComponent("CommandLineTools.scpt").path)
    }
    
    fileprivate func installScriptAndCmds (_ completion: @escaping (Bool) -> Void) {
        
        installScript(script: "CommandLineTools", { success in
            self.installCmds(completion)
        })
    }
    
    fileprivate func installScript (script: String, _ completion: @escaping (Bool) -> Void) {
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = script + ".scpt"
        panel.directoryURL = scripts.scriptsDirectory!
        panel.message = "Please select: User / Library / Application Scripts / com.ralcr.Jirassic.osx"
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
                
                let scriptPath = Bundle.main.url(forResource: script, withExtension: ".scpt")
                do {
                    try? self.manager.copyItem(at: scriptPath!, to: panel.url!)
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    fileprivate func uninstallScript (atUrl url: URL, _ completion: @escaping (Bool) -> Void) {
        
        do {
            try? self.manager.removeItem(at: url)
            completion(true)
        }
    }
    
    fileprivate func installCmds (_ completion: @escaping (Bool) -> Void) {
        
        let bundlePath = Bundle.main.url(forResource: "jit", withExtension: nil)!.deletingLastPathComponent()
        
        scripts.copyFile(from: bundlePath.path + "/", to: localBinPath, completion: { success in
            completion(success)
        })
    }
    
    fileprivate func uninstallCmds (_ completion: @escaping (Bool) -> Void) {
        
        scripts.removeFile(from: localBinPath, completion: { success in
            completion(success)
        })
    }
}
