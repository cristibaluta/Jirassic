//
//  JitInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import Cocoa
import CoreServices

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
        
        guard let bundledJitPath = Bundle.main.url(forResource: "jit", withExtension: nil) else {
            completion(false)
            return
        }
//        let downloadsPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0]
//        
//        do {
//            let f = FileManager.default.contents(atPath: bundledJitPath.path)
//            try f?.write(to: URL(fileURLWithPath: "\(downloadsPath)/jit", isDirectory: false))
//        } catch let e as NSError {
//            print("err \(e)")
//        } catch {
//            print("")
//        }
        
//        let asc = NSAppleScript(source: "do shell script \"sudo ./\(bundledJitPath) install\"")
//        var errorInfo: NSDictionary?
//        if let response = asc?.executeAndReturnError(&errorInfo) {
//            print(response)
//            completion(true)
//        } else {
//            print(errorInfo)
//            completion(false)
//        }
        
        var directoryURL: URL?
        do {
            directoryURL = try? FileManager.default.url(for: .applicationScriptsDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor:nil, create:true)
        } catch {
            
        }

//        let scriptURL = directoryURL?.appendingPathComponent("Installer.scpt")
//        
//        do {
//            var pid = ProcessInfo.processInfo.processIdentifier
//            
//            let targetDescriptor = NSAppleEventDescriptor(descriptorType: typeKernelProcessID, bytes: &pid, length: MemoryLayout.size(ofValue: pid))
//            
//            let appleEventDescriptor = NSAppleEventDescriptor.appleEvent(withEventClass: kCoreEventClass,
//                                                                         eventID: kAEOpenDocuments,
//                                                                         targetDescriptor: targetDescriptor,
//                                                                         returnID: AEReturnID(kAutoGenerateReturnID),
//                                                                         transactionID: AETransactionID(kAnyTransactionID))
//            
//            let list = NSAppleEventDescriptor.list()
//            list.insert(NSAppleEventDescriptor(string: "path"), at: 1)
//            
//            appleEventDescriptor.setParam(list, forKeyword: keyDirectObject)
//            
//            let result = try NSUserAppleScriptTask(url: scriptURL!)
//            result.execute(withAppleEvent: appleEventDescriptor, completionHandler: { (descriptor, error) in
//                print(descriptor)
//                print(error)
//            })
//        } catch {
//            
//        }
        
        
//        let openPanel = NSOpenPanel()
//        openPanel.directoryURL = directoryURL
//        openPanel.canChooseDirectories = true
//        openPanel.canChooseFiles = false
//        openPanel.prompt = "Select Script Folder"
//        openPanel.message = "Please select the User > Library > Application Scripts > com.iconfactory.Scriptinator folder"
//        openPanel.begin { [weak self] (result) -> Void in
//            
//            let selectedURL = openPanel.url
//            let destinationURL = selectedURL?.appendingPathComponent("Automation.scpt")
//            let f = FileManager.default.contents(atPath: bundledJitPath.path)
//            do {
//               try f?.write(to: destinationURL!)
//            } catch {
//                
//            }
//        }
        
//        let panel = NSSavePanel()
//        panel.nameFieldStringValue = "jit"
//        panel.directoryURL = URL(string: jitInstallationPath)
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
//    func installJit (_ completion: (Bool) -> Void) {
//        
//        guard let bundledJitPath = Bundle.main.path(forResource: "jit", ofType: nil) else {
//            completion(false)
//            return
//        }
//        let asc = NSAppleScript(source: "do shell script \"sudo cp \(bundledJitPath) \(jitInstallationPath)\" with administrator privileges")
//        if let response = asc?.executeAndReturnError(nil) {
//            print(response)
//            completion(true)
//        } else {
//            print("Could not copy Jit from \(bundledJitPath) to \(jitInstallationPath)")
//            completion(false)
//        }
//    }
    
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
