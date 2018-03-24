//
//  AppleScript.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation
import CoreServices
import Carbon.OpenScripting

fileprivate let commandRunShellScript = "runShellScript"
fileprivate let commandGetScriptVersion = "getScriptVersion"
fileprivate let commandGetBrowserInfo = "getBrowserInfo"

class AppleScript: AppleScriptProtocol {
    
    private func validateTarget() {
        #if APPSTORE
            fatalError("For sandboxed apps, SandboxedAppleScript must be used")
        #endif
    }
    
    var scriptsDirectory: URL? {
        validateTarget()
        return Bundle.main.resourceURL
    }
    
    func run (command: String, completion: @escaping (String?) -> Void) {
        
        RCLog("-------------------------------------------------")
        RCLog("Running command: \(command)")
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: command), at: 1)
        
        run (command: commandRunShellScript, scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
            if let descriptor = descriptor, let result = descriptor.stringValue {
                RCLog("Result: \(result)")
                RCLog("-------------------------------------------------")
                completion(result)
            } else {
                completion(nil)
            }
        })
    }
    
    func getScriptVersion (script: String, completion: @escaping (String) -> Void) {
        
        run (command: commandGetScriptVersion, scriptNamed: script, args: nil, completion: { descriptor in
            if let descriptor = descriptor, let result = descriptor.stringValue {
                completion(result)
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
                            dict = _d
                        }
                    }
                }
            }
            
            completion(dict)
        })
    }
    
    func getJirassicVersion (completion: @escaping (String) -> Void) {
        
        let command = "/usr/local/bin/jirassic version"
        let args = NSAppleEventDescriptor.list()
        args.insert(NSAppleEventDescriptor(string: command), at: 1)
        
        run (command: commandRunShellScript, scriptNamed: kShellSupportScriptName, args: args, completion: { descriptor in
            if let descriptor = descriptor, let result = descriptor.stringValue {
                completion(result)
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
                completion("", "")
            }
        })
    }
    
    func downloadFile (from: String, to: String, completion: @escaping (Bool) -> Void) {
        
//        let asc = NSAppleScript(source: "do shell script \"sudo cp \(from) \(to)\" with administrator privileges")
        
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: URL(string: from)!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    RCLog("Success: \(statusCode)")
                }
                
//                do {
//                    try FileManager.default.copyItem(at: tempLocalUrl, to: URL(fileURLWithPath: to))
//                    completion(true)
//                } catch (let writeError) {
//                    print("error writing file \(to) : \(writeError)")
//                    completion(false)
//                }
                
                RCLog(from)
                RCLog(to)
                let asc = NSAppleScript(source: "do shell script \"sudo cp \(tempLocalUrl.path) \(to)\" with administrator privileges")
                if let response = asc?.executeAndReturnError(nil) {
                    RCLog(response)
                    let asc = NSAppleScript(source: "chmod +x \(to)")
                    if let response = asc?.executeAndReturnError(nil) {
                        RCLog(response)
                        completion(true)
                    } else {
                        RCLog("Could not download Jit from \(from) to \(to)")
                        completion(false)
                    }
                } else {
                    RCLog("Could not download Jit from \(from) to \(to)")
                    completion(false)
                }
                
            } else {
                RCLog("Failure: \(error!.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func removeFile (from: String, completion: @escaping (Bool) -> Void) {
        
    }
}

extension AppleScript {
    
    fileprivate func run (command: String,
                          scriptNamed: String,
                          args: NSAppleEventDescriptor?,
                          completion: @escaping (NSAppleEventDescriptor?) -> Void) {
        
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
