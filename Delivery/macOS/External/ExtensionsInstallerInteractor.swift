//
//  ExtensionsInstallerInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 14/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa

class ExtensionsInstallerInteractor: ExtensionsInteractor {
    
    fileprivate let scripts: AppleScriptProtocol = AppleScript()
    fileprivate let fileManager = FileManager.default
    
//    func saveJiraSettings (_ settings: JiraSettings, completion: @escaping (Bool) -> Void) {
//        
//        var values = "jira_url=\(settings.url!)\njira_user=\(settings.user!)"
//        if let password = settings.password {
//            values += "\njira_password=\(password)"
//        }
//        
//        scripts.setupJitWithValues(values, completion: { success in
//            completion(success)
//        })
//    }
    
    func installJirassic (_ completion: @escaping (Bool) -> Void) {
        
        scripts.downloadFile(from: "https://raw.githubusercontent.com/ralcr/Jit/master/build/jit", to: "/usr/local/bin/jirassic", completion: { success in
            completion(success)
        })
    }
    
    func installJit (_ completion: @escaping (Bool) -> Void) {
        
        scripts.downloadFile(from: "https://raw.githubusercontent.com/ralcr/Jit/master/build/jit", to: "/usr/local/bin/jit", completion: { success in
            completion(success)
        })
    }
    
    func uninstallTools (_ completion: @escaping (Bool) -> Void) {
        
        if isShellSupportInstalled() {
            uninstallCmds({ success in
                if success {
                    
                    if let bookmark = UserDefaults.standard.object(forKey: kShellSupportScriptName) as? NSData as Data? {
                        var stale = false
                        if let url = try? URL(resolvingBookmarkData: bookmark, options: URL.BookmarkResolutionOptions.withSecurityScope,
                                              relativeTo: nil,
                                              bookmarkDataIsStale: &stale) {
                            
                            let _ = url.startAccessingSecurityScopedResource()
                            self.uninstallScript(atUrl: url, completion)
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    
                    //                    let scriptsDirectory = self.scripts.scriptsDirectory!
                    //                    let scriptUrl = scriptsDirectory.appendingPathComponent("\(self.scriptsName).scpt")
                    //                    self.uninstallScript(atUrl: scriptUrl, completion)
                } else {
                    completion(false)
                }
            })
        } else {
            completion(false)
        }
    }
}

extension ExtensionsInstallerInteractor {
    
    fileprivate func isShellSupportInstalled() -> Bool {
        let scriptsDirectory = scripts.scriptsDirectory!
        return fileManager.fileExists(atPath: scriptsDirectory.appendingPathComponent("\(kShellSupportScriptName).scpt").path)
    }
    
    fileprivate func isBrowserSupportInstalled() -> Bool {
        let scriptsDirectory = scripts.scriptsDirectory!
        return fileManager.fileExists(atPath: scriptsDirectory.appendingPathComponent("\(kBrowserSupportScriptName).scpt").path)
    }
    
    fileprivate func installScriptAndCmds (_ completion: @escaping (Bool) -> Void) {
        
        installScript(script: kShellSupportScriptName, { success in
            self.installJit(completion)
        })
    }
    
    fileprivate func installScript (script: String, _ completion: @escaping (Bool) -> Void) {
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(script).scpt"
        panel.directoryURL = scripts.scriptsDirectory!
        panel.message = "Please select: User / Library / Application Scripts / com.ralcr.Jirassic.osx"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        panel.begin { (result) in
            
            if result.rawValue == NSFileHandlingPanelOKButton {
                
                let scriptPath = Bundle.main.url(forResource: script, withExtension: ".scpt")
                do {
                    try? self.fileManager.copyItem(at: scriptPath!, to: panel.url!)
                    
                    let bookmark = try? panel.url!.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                                includingResourceValuesForKeys: nil,
                                                                relativeTo: nil)
                    
                    UserDefaults.standard.set(bookmark, forKey: kShellSupportScriptName)
                    UserDefaults.standard.synchronize()
                    
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    fileprivate func uninstallScript (atUrl url: URL, _ completion: @escaping (Bool) -> Void) {
        try? fileManager.removeItem(at: url)
        completion(true)
    }
    
//    fileprivate func installJit (_ completion: @escaping (Bool) -> Void) {
//        
//        let bundlePath = Bundle.main.url(forResource: "jit", withExtension: nil)!.deletingLastPathComponent()
//        
//        scripts.downloadFile(from: bundlePath.path + "/", to: kLocalBinPath, completion: { success in
//            completion(success)
//        })
//    }
    
    fileprivate func uninstallCmds (_ completion: @escaping (Bool) -> Void) {
        
        scripts.removeFile(from: kLocalBinPath, completion: { success in
            completion(success)
        })
    }
}
