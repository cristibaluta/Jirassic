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
        
        let bundlePath = Bundle.main.url(forResource: "jit", withExtension: nil)!.deletingLastPathComponent()
        scripts.copyFile(from: bundlePath.path + "/", to: localBinPath, completion: { success in
            completion(success)
        })
        
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
    
    func uninstallJit (_ completion: @escaping (Bool) -> Void) {
        
        scripts.removeFile(from: localBinPath, completion: { success in
            completion(success)
        })
    }
}
