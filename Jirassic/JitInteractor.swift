//
//  JitInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class JitInteractor {
    
    fileprivate let jitInstallationPath = "/usr/local/bin/"
    
    var isInstalled: Bool {
        get {
            let asc = NSAppleScript(source: "do shell script \"\(jitInstallationPath)jit\"")
            if let response = asc?.executeAndReturnError(nil) {
                print(response)
                return true
            } else {
                print("Could not find Jit at \(jitInstallationPath)")
                return false
            }
        }
    }
    
    func installJit (_ completion: (Bool) -> Void) {
        
        guard let bundledJitPath = Bundle.main.path(forResource: "jit", ofType: nil) else {
            completion(false)
            return
        }
        let asc = NSAppleScript(source: "do shell script \"sudo cp \(bundledJitPath) \(jitInstallationPath)\" with administrator privileges")
        if let response = asc?.executeAndReturnError(nil) {
            print(response)
            completion(true)
        } else {
            print("Could not copy Jit from \(bundledJitPath) to \(jitInstallationPath)")
            completion(false)
        }
    }
    
    func uninstallJit (_ completion: (Bool) -> Void) {
        
        let asc = NSAppleScript(source: "do shell script \"sudo rm \(jitInstallationPath)jit\" with administrator privileges")
        if let response = asc?.executeAndReturnError(nil) {
            print(response)
            completion(true)
        } else {
            print("Could not delete Jit from \(jitInstallationPath)")
            completion(false)
        }
    }
}
