//
//  SandboxedScriptsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation
import CoreServices

class SandboxedScriptsInteractor: ScriptsInteractorProtocol {
    
    func scriptsDirectory() -> URL? {
        
        return try? FileManager.default.url(for: .applicationScriptsDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
    
    func getVersion (completion: @escaping ([String: String]) -> Void) {
        
        guard let scriptsDirectory = scriptsDirectory() else {
            completion([:])
            return
        }
        let scriptURL = scriptsDirectory.appendingPathComponent("GetJitVersion.scpt")
        let result = try? NSUserAppleScriptTask(url: scriptURL)
        result?.execute(withAppleEvent: nil, completionHandler: { (descriptor, error) in
            
            var dict: [String: String] = [:]
            if let descriptor = descriptor {
                
                let validJson = descriptor.stringValue!.replacingOccurrences(of: "'", with: "\"")
                if let data = validJson.data(using: String.Encoding.utf8) {
                    if let d = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                        if let d = d {
                            dict = d
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
        
        run(script: "Installer.scpt", args: args, completion: completion)
    }
    
    func removeFile (from: String, completion: @escaping (Bool) -> Void) {
        
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: from), at: 1)
        
        run(script: "Uninstaller.scpt", args: args, completion: completion)
    }
}

extension SandboxedScriptsInteractor {
    
    fileprivate func run (script: String, args: NSAppleEventDescriptor, completion: @escaping (Bool) -> Void) {
        
        guard let scriptsDirectory = scriptsDirectory() else {
            completion(false)
            return
        }
        let scriptURL = scriptsDirectory.appendingPathComponent(script)
        
        do {
            var pid = ProcessInfo.processInfo.processIdentifier
            
            let targetDescriptor = NSAppleEventDescriptor(descriptorType: typeKernelProcessID,
                                                          bytes: &pid,
                                                          length: MemoryLayout.size(ofValue: pid))
            
            let appleEventDescriptor = NSAppleEventDescriptor.appleEvent(withEventClass: kCoreEventClass,
                                                                         eventID: kAEOpenDocuments,
                                                                         targetDescriptor: targetDescriptor,
                                                                         returnID: AEReturnID(kAutoGenerateReturnID),
                                                                         transactionID: AETransactionID(kAnyTransactionID))
            
            appleEventDescriptor.setParam(args, forKeyword: keyDirectObject)
            
            let result = try NSUserAppleScriptTask(url: scriptURL)
            result.execute(withAppleEvent: appleEventDescriptor, completionHandler: { (descriptor, error) in
                RCLogErrorO(error)
                completion(error == nil)
            })
        } catch {
            completion(false)
        }
    }
}
