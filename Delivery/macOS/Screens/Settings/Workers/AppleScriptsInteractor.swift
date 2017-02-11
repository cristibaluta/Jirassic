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
    
    fileprivate let scriptsName = "CommandLineTools"
    fileprivate let localBinPath = "/usr/local/bin/"
    fileprivate let scripts: AppleScriptInstallerProtocol = SandboxedAppleScriptInstaller()
    fileprivate let manager = FileManager.default
    
    func getJiraSettings (completion: @escaping ([String: String]) -> Void) {
        
        scripts.getJitVersion(completion: { dict in
            completion(dict)
        })
    }
    
    func saveJiraSettings (_ settings: JiraSettings, completion: @escaping (Bool) -> Void) {
        
        var values = "jira_url=\(settings.url!)\njira_user=\(settings.user!)"
        if let password = settings.password {
            values += "\njira_password=\(password)"
        }
        
        scripts.setupJitWithValues(values, completion: { success in
            completion(success)
        })
    }
    
    func getSafariUrl (completion: @escaping (String) -> Void) {
        scripts.getSafariUrl(completion: completion)
    }
    
    func checkTools (completion: @escaping (_ installed: Bool, _ compatible: Bool) -> Void) {
        
        guard isScriptInstalled() else {
            completion(false, false)
            return
        }
        scripts.getScriptsVersion(completion: { scriptsVersion in
            self.scripts.getJitVersion(completion: { dict in
                let jitVersion = dict["version"] ?? ""
                self.scripts.getJirassicVersion(completion: { jirassicVersion in
                    let versions = Versions(scripts: scriptsVersion, jitCmd: jitVersion, jirassicCmd: jirassicVersion)
                    completion( true, Versioning.isCompatibleWithTools(versions) )
                })
            })
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
                    let scriptUrl = scriptsDirectory.appendingPathComponent("\(self.scriptsName).scpt")
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
        return manager.fileExists(atPath: scriptsDirectory.appendingPathComponent("\(scriptsName).scpt").path)
    }
    
    fileprivate func installScriptAndCmds (_ completion: @escaping (Bool) -> Void) {
        
        installScript(script: scriptsName, { success in
            self.installCmds(completion)
        })
    }
    
    fileprivate func installScript (script: String, _ completion: @escaping (Bool) -> Void) {
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(script).scpt"
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
