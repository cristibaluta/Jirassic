//
//  JitInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import Cocoa

class JitInteractor {
    
    fileprivate let localBinPath = "/usr/local/bin/"
    fileprivate let scripts: ScriptsInteractorProtocol = SandboxedScriptsInteractor()
    
    func getJiraSettings (completion: @escaping ([String: String]) -> Void) {
        
        scripts.getVersion(completion: { dict in
            completion(dict)
        })
    }
    
    func isInstalled (completion: @escaping (Bool) -> Void) {
        
        scripts.getVersion(completion: { dict in
            let isInstalled = dict["version"] != nil
            completion(isInstalled)
        })
    }
    
    func installJit (_ completion: @escaping (Bool) -> Void) {
        
        let manager = FileManager.default
        let scriptsDirectory = scripts.scriptsDirectory()!
        
        guard manager.fileExists(atPath: scriptsDirectory.appendingPathComponent("Installer.scpt").path) else {
            installScripts(completion)
            return
        }
        guard manager.fileExists(atPath: scriptsDirectory.appendingPathComponent("Uninstaller.scpt").path) else {
            installScripts(completion)
            return
        }
        guard manager.fileExists(atPath: scriptsDirectory.appendingPathComponent("GetJitVersion.scpt").path) else {
            installScripts(completion)
            return
        }
        installCmds(completion)
    }
    
    func uninstallJit (_ completion: @escaping (Bool) -> Void) {
        
        scripts.removeFile(from: localBinPath, completion: { success in
            completion(success)
        })
    }
}

extension JitInteractor {
    
    fileprivate func installScripts (_ completion: @escaping (Bool) -> Void) {
        
        installScript(script: "GetJitVersion", { success in
            self.installScript(script: "Installer", { success in
                self.installScript(script: "Uninstaller", { success in
                    self.installCmds(completion)
                })
            })
        })
    }
    
    fileprivate func installScript (script: String, _ completion: @escaping (Bool) -> Void) {
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = script
        panel.directoryURL = scripts.scriptsDirectory()!
        panel.message = "Please select the User > Library > Application Scripts > com.ralcr.Jirassic.osx folder"
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
                
                let scriptPath = Bundle.main.url(forResource: script, withExtension: ".scpt")
                do {
                    try? FileManager.default.copyItem(at: scriptPath!, to: panel.url!)
                    self.installCmds(completion)
                }
            }
        }
    }
    
    func installCmds (_ completion: @escaping (Bool) -> Void) {
        
        let bundlePath = Bundle.main.url(forResource: "jit", withExtension: nil)!.deletingLastPathComponent()
        scripts.copyFile(from: bundlePath.path + "/", to: localBinPath, completion: { success in
            completion(success)
        })
    }
}
