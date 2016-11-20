//
//  SandboxedScriptsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa
import CoreServices

class SandboxedScriptsInteractor: ScriptsInteractorProtocol {
    
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
        
        guard let scriptsDirectory = scriptsDirectory() else {
            return
        }
        let scriptURL = scriptsDirectory.appendingPathComponent("Installer.scpt")
        
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
            
            let list = NSAppleEventDescriptor.list()
            list.insert(NSAppleEventDescriptor(string: from), at: 1)
            list.insert(NSAppleEventDescriptor(string: to), at: 2)
            
            appleEventDescriptor.setParam(list, forKeyword: keyDirectObject)
            
            let result = try NSUserAppleScriptTask(url: scriptURL)
            result.execute(withAppleEvent: appleEventDescriptor, completionHandler: { (descriptor, error) in
                RCLogO(descriptor)
                RCLogErrorO(error)
                completion(error == nil)
            })
        } catch {
            completion(false)
        }
    }
    
    func removeFile (from: String, completion: @escaping (Bool) -> Void) {
        
        guard let scriptsDirectory = scriptsDirectory() else {
            return
        }
        let scriptURL = scriptsDirectory.appendingPathComponent("Uninstaller.scpt")
        
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
            
            let list = NSAppleEventDescriptor.list()
            list.insert(NSAppleEventDescriptor(string: from), at: 1)
            
            appleEventDescriptor.setParam(list, forKeyword: keyDirectObject)
            
            let result = try NSUserAppleScriptTask(url: scriptURL)
            result.execute(withAppleEvent: appleEventDescriptor, completionHandler: { (descriptor, error) in
                RCLogO(descriptor)
                RCLogErrorO(error)
                completion(error == nil)
            })
        } catch {
            completion(false)
        }
    }
}

extension SandboxedScriptsInteractor {
    
    fileprivate func scriptsDirectory() -> URL? {
        
        return try? FileManager.default.url(for: .applicationScriptsDirectory,
                                            in: FileManager.SearchPathDomainMask.userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
}
