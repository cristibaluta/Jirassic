//
//  SandboxedAppleScriptt.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation
import CoreServices
import Carbon.OpenScripting

class SandboxedAppleScript: AppleScriptProtocol {
    
    fileprivate let commandRunShellScript = "runShellScript"
    fileprivate let commandGetScriptVersion = "getScriptVersion"
    fileprivate let commandGetBrowserInfo = "getBrowserInfo"
    
    var scriptsDirectory: URL? {
        
        return try? FileManager.default.url(for: .applicationScriptsDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
    
    func getScriptVersion (script: String, completion: @escaping (String) -> Void) {
        
        run (command: commandGetScriptVersion, scriptNamed: script, args: nil, completion: { descriptor in
            if let descriptor = descriptor {
                completion( descriptor.stringValue! )
            } else {
                completion("")
            }
        })
    }
    
    func getJitInfo (completion: @escaping ([String: String]) -> Void) {
        
        let command = "/usr/local/bin/jit info"
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: command), at: 1)
        
        run (command: commandRunShellScript, scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
            
            var dict: [String: String] = [:]
            if let descriptor = descriptor {
                
                let validJson = descriptor.stringValue!.replacingOccurrences(of: "'", with: "\"")
                if let data = validJson.data(using: String.Encoding.utf8) {
                    if let d = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                        if let _d = d {
                            print(_d)
                            dict = _d
                        }
                    }
                }
            }
            
            completion(dict)
        })
    }
    
    func getGitLogs (for day: Date, completion: @escaping (String) -> Void) {
        // error "fatal: Not a git repository (or any of the parent directories): .git" number 128
        // do shell script "git -C ~/Documents/Jirassic log"
    }
    
    func call (command: String, arguments: [String: Any], completion: @escaping (String) -> Void) {
        
        let command = "/usr/local/bin/jirassic version"
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: command), at: 1)
        
        run (command: commandRunShellScript, scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
            if let descriptor = descriptor {
                completion( descriptor.stringValue! )
            } else {
                completion("")
            }
        })
    }
    
    func getJirassicVersion (completion: @escaping (String) -> Void) {
        
        let command = "/usr/local/bin/jirassic version"
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: command), at: 1)
        
        run (command: commandRunShellScript, scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
            if let descriptor = descriptor {
                completion( descriptor.stringValue! )
            } else {
                completion("")
            }
        })
    }
    
    func getBrowserInfo (browserId: String, completion: @escaping (String, String) -> Void) {
        
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: browserId), at: 1)
        
        run (command: commandGetBrowserInfo, scriptNamed: kBrowserSupportScriptName, args: args, completion: { descriptor in
            if let descriptor = descriptor {
                let url = descriptor.atIndex(1)?.stringValue ?? ""
                let title = descriptor.atIndex(1)?.stringValue ?? ""
                completion(url, title)
            } else {
                RCLog("Cannot get browser info")
            }
        })
    }
    
    func downloadFile (from: String, to: String, completion: @escaping (Bool) -> Void) {
        
        fatalError("Copy files not supported in AppStore")
//        let args = NSAppleEventDescriptor.list()
//        args.insert(NSAppleEventDescriptor(string: from), at: 1)
//        args.insert(NSAppleEventDescriptor(string: to), at: 2)
//        
//        run (command: "install", scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
//            completion(descriptor != nil)
//        })
    }
    
    func removeFile (from: String, completion: @escaping (Bool) -> Void) {
        
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: from), at: 1)
        
        run (command: "uninstall", scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
            completion(descriptor != nil)
        })
    }
}

extension SandboxedAppleScript {
    
    fileprivate func run (command: String, scriptNamed: String, args: NSAppleEventDescriptor?, completion: @escaping (NSAppleEventDescriptor?) -> Void) {
        
        guard let scriptsDirectory = self.scriptsDirectory else {
            completion(nil)
            return
        }
        let scriptURL = scriptsDirectory.appendingPathComponent(scriptNamed + ".scpt")
        
        do {
            var pid = ProcessInfo.processInfo.processIdentifier
            
            let targetDescriptor = NSAppleEventDescriptor(descriptorType: typeKernelProcessID,
                                                          bytes: &pid,
                                                          length: MemoryLayout.size(ofValue: pid))
            
            let theEvent = NSAppleEventDescriptor.appleEvent(withEventClass: AEEventClass(kASAppleScriptSuite),//kCoreEventClass,
                                                             eventID: AEEventID(kASSubroutineEvent),//kAEOpenDocuments,
                                                             targetDescriptor: targetDescriptor,
                                                             returnID: AEReturnID(kAutoGenerateReturnID),
                                                             transactionID: AETransactionID(kAnyTransactionID))
            
            let commandDescriptor = NSAppleEventDescriptor(string: command)
            theEvent.setDescriptor(commandDescriptor, forKeyword: AEKeyword(keyASSubroutineName))
            
            if let args = args {
                theEvent.setDescriptor(args, forKeyword: keyDirectObject)
            }
            
            let result = try NSUserAppleScriptTask(url: scriptURL)
            result.execute(withAppleEvent: theEvent, completionHandler: { (descriptor, error) in
//                RCLogO(descriptor)
//                RCLogErrorO(error)
                DispatchQueue.main.sync {
                    completion(descriptor)
                }
            })
        } catch {
            completion(nil)
        }
    }
}
