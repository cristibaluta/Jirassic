//
//  Hookup.swift
//  Jirassic
//
//  Created by Cristian Baluta on 26/11/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class ModuleHookup {
    
    private let extensions = ExtensionsInteractor()
    private let localPreferences = RCPreferences<LocalPreferences>()
    
    func isHookupInstalled (completion: @escaping (Bool) -> Void) {
        let cmd = localPreferences.string(.settingsHookupCmdName)
        checkIfCommandInstalled(cmd: cmd, completion: completion)
    }
    
    func insert (task: Task) {
        let cmd = localPreferences.string(.settingsHookupCmdName)
        RCLog("Sending this task \(task) to hookup: \(cmd)")
    }
}

extension ModuleHookup {
    
    func checkIfCommandInstalled (cmd: String, completion: @escaping (Bool) -> Void) {
        
        let command = "command -v \(cmd)"// Returns the path to git if exists
        extensions.run (command: command, completion: { result in
            completion(result != nil)
        })
    }
    
}
