//
//  SandboxedAppleScriptInstaller.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation
import CoreServices
import Carbon.OpenScripting

class SandboxedAppleScriptInstaller: AppleScriptInstallerProtocol {
    
    var scriptsDirectory: URL? {
        
        return try? FileManager.default.url(for: .applicationScriptsDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
    
    func getVersion (completion: @escaping ([String: String]) -> Void) {
        
        run (command: "getJitVersion", args: nil, completion: { descriptor in
            
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
    
    func copyFile (from: String, to: String, completion: @escaping (Bool) -> Void) {
        
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: from), at: 1)
        args.insert(NSAppleEventDescriptor(string: to), at: 2)
        
        run (command: "install", args: args, completion: { descriptor in
            completion(descriptor != nil)
        })
    }
    
    func removeFile (from: String, completion: @escaping (Bool) -> Void) {
        
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: from), at: 1)
        
        run (command: "uninstall", args: args, completion: { descriptor in
            completion(descriptor != nil)
        })
    }
}

extension SandboxedAppleScriptInstaller {
    
    fileprivate func run (command: String, args: NSAppleEventDescriptor?, completion: @escaping (NSAppleEventDescriptor?) -> Void) {
        
        guard let scriptsDirectory = self.scriptsDirectory else {
            completion(nil)
            return
        }
        let scriptURL = scriptsDirectory.appendingPathComponent("CommandLineTools.scpt")
        
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
                RCLogO(descriptor)
                RCLogErrorO(error)
                DispatchQueue.main.sync {
                    completion(descriptor)
                }
            })
        } catch {
            completion(nil)
        }
    }
}
