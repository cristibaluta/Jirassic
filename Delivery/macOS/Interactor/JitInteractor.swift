//
//  JitInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

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
    
    func installJit (_ completion: (Bool) -> Void) {
        
        guard let bundledJitPath = Bundle.main.url(forResource: "jit", withExtension: nil) else {
            completion(false)
            return
        }
        guard let bundledJirrasicPath = Bundle.main.url(forResource: "jirassic", withExtension: nil) else {
            completion(false)
            return
        }
        scripts.copyFile(from: bundledJitPath.path, to: localBinPath + "jit", completion: { success in
            
        })
        scripts.copyFile(from: bundledJirrasicPath.path, to: localBinPath + "jirassic", completion: { success in
            
        })
        

        
//        let asc = NSAppleScript(source: "do shell script \"sudo ./\(bundledJitPath) install\"")
//        var errorInfo: NSDictionary?
//        if let response = asc?.executeAndReturnError(&errorInfo) {
//            print(response)
//            completion(true)
//        } else {
//            print(errorInfo)
//            completion(false)
//        }
        
        
        
//        let openPanel = NSOpenPanel()
//        openPanel.directoryURL = directoryURL
//        openPanel.canChooseDirectories = true
//        openPanel.canChooseFiles = false
//        openPanel.prompt = "Select Script Folder"
//        openPanel.message = "Please select the User > Library > Application Scripts > com.iconfactory.Scriptinator folder"
//        openPanel.begin { [weak self] (result) -> Void in
//            
//            let selectedURL = openPanel.url
//            let destinationURL = selectedURL?.appendingPathComponent("Automation.scpt")
//            let f = FileManager.default.contents(atPath: bundledJitPath.path)
//            do {
//               try f?.write(to: destinationURL!)
//            } catch {
//                
//            }
//        }
        
//        let panel = NSSavePanel()
//        panel.nameFieldStringValue = "jit"
//        panel.directoryURL = URL(string: jitInstallationPath)
//        panel.message = "Please select the User > Library > Application Scripts > com.ralcr.Jirassic.osx folder"
//
//        panel.begin { (result) in
//        
//            if result == NSFileHandlingPanelOKButton {
//            
//                let manager = FileManager.default
//                let saveURL = panel.url
//                do {
//                    try? manager.copyItem(at: bundledJitPath, to: saveURL!)
//                } catch let err {
//                    print(err)
//                }
//            }
//        }
    }
    
    func uninstallJit (_ completion: (Bool) -> Void) {
        
        scripts.removeFile(from: localBinPath + "jit", completion: { success in
            
        })
        scripts.removeFile(from: localBinPath + "jirassic", completion: { success in
            
        })
    }
}
