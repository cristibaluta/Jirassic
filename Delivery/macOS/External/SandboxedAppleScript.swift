//
//  SandboxedAppleScriptt.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation

class SandboxedAppleScript: AppleScript {
    
    override var scriptsDirectory: URL? {
        
        return try? FileManager.default.url(for: .applicationScriptsDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
    
    override func downloadFile (from: String, to: String, completion: @escaping (Bool) -> Void) {
        
        fatalError("File manipulation not supported in AppStore")
//        let args = NSAppleEventDescriptor.list()
//        args.insert(NSAppleEventDescriptor(string: from), at: 1)
//        args.insert(NSAppleEventDescriptor(string: to), at: 2)
//        
//        run (command: "install", scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
//            completion(descriptor != nil)
//        })
    }
    
    override func removeFile (from: String, completion: @escaping (Bool) -> Void) {
        
        fatalError("File manipulation not supported in AppStore")
//        let args = NSAppleEventDescriptor.list()
//        args.insert(NSAppleEventDescriptor(string: from), at: 1)
//
//        run (command: "uninstall", scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
//            completion(descriptor != nil)
//        })
    }
}

