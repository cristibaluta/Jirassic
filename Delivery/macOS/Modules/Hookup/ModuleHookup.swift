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
    
    func isCmdReachable (completion: @escaping (Bool) -> Void) {
        
        let cmd = localPreferences.string(.settingsHookupCmdName)
        checkIfCommandInstalled(cmd: cmd, completion: completion)
    }
    
    func isAppReachable (completion: @escaping (Bool) -> Void) {
        
        let appName = localPreferences.string(.settingsHookupAppName)
        checkIfAppInstalled(appName: appName, completion: completion)
    }
    
    func insert (task: Task, completion: ((_ success: Bool) -> Void)? = nil) {
        
        let isHookupEnabled = localPreferences.bool(.enableHookup)
        let isCocoaHookupEnabled = localPreferences.bool(.enableCocoaHookup)
        
        // Call cli hookup
        if isHookupEnabled {
            let cliName = localPreferences.string(.settingsHookupCmdName)
            let json = buildJson (task: task)
            let command = "\(cliName) insert \"\(json)\""
            
            extensions.run (command: command, completion: { result in
                
                guard let validJson = result else {
                    completion?(false)
                    return
                }
                guard let data = validJson.data(using: String.Encoding.utf8) else {
                    completion?(false)
                    return
                }
                guard let jdict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                    let dict = jdict else {
                    completion?(false)
                    return
                }
                RCLog(dict)
                completion?(dict["success"] == "true")
            })
        }
        
        // Call cocoa hookups
        // Only start/end types are supported
        if isCocoaHookupEnabled {
            let appName = localPreferences.string(.settingsHookupAppName)
            var command = ""
            if task.taskType == .startDay {
                command = "osascript -e \"tell application \\\"\(appName)\\\" to start\""
            } else if task.taskType == .endDay {
                command = "osascript -e \"tell application \\\"\(appName)\\\" to stop\""
            }
            if command != "" {
                extensions.run (command: command, completion: { result in
                    // Do nothing
                })
            }
        }
    }
    
    /// Json sent to shell to be valid must be a string with ' instead of " and no breaklines
    private func buildJson (task: Task) -> String {
        
        var jsonCredentials = "'credentials':{}"
        if localPreferences.bool(.enableHookupCredentials) {
            let url = localPreferences.string(.settingsJiraUrl)
            let user = localPreferences.string(.settingsJiraUser)
            let password = Keychain.getPassword()
            jsonCredentials = "'credentials':{'url':'\(url)', 'user':'\(user)', 'password':'\(password)'}"
        }
        let jsonTask = "'task':{'taskType':\(task.taskType.rawValue)}"
        
        return "{\(jsonCredentials), \(jsonTask)}"
    }
}

extension ModuleHookup {
    
    func checkIfCommandInstalled (cmd: String, completion: @escaping (Bool) -> Void) {
        
        let command = "command -v \(cmd)"// Returns the path to git if exists
        extensions.run (command: command, completion: { result in
            completion(result != nil)
        })
    }
    
    func checkIfAppInstalled (appName: String, completion: @escaping (Bool) -> Void) {
        
        //let command = "command -v \(cmd)"// Returns the path to git if exists
        //extensions.run (command: command, completion: { result in
            completion(true)
        //})
    }
    
}
