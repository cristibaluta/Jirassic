//
//  CMDToolsInstaller.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import Cocoa

class ExtensionsInteractor {
    
    fileprivate let shellSupportScriptName = "ShellSupport"
    fileprivate let codeReviewScriptName = "CodeReview"
    fileprivate let localBinPath = "/usr/local/bin/"
    fileprivate let scripts: AppleScriptProtocol = SandboxedAppleScript()
    fileprivate let fileManager = FileManager.default
    
    func getJiraSettings (completion: @escaping ([String: String]) -> Void) {
        
        scripts.getJitInfo(completion: { dict in
            completion(dict)
        })
    }
    
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
    
    func getBrowserInfo (browserId: String, completion: @escaping (String, String) -> Void) {
        scripts.getBrowserInfo(browserId: browserId, completion: completion)
    }
    
    func getVersions (completion: @escaping (_ versions: VersionsCompatibility) -> Void) {
        
        scripts.getScriptVersion (script: shellSupportScriptName, completion: { shellSupportScriptVersion in
            self.scripts.getScriptVersion (script: self.codeReviewScriptName, completion: { codeReviewScriptVersion in
            
                self.scripts.getJitInfo(completion: { dict in
                    let jitVersion = dict["version"] ?? ""
                    
                    self.scripts.getJirassicVersion(completion: { jirassicVersion in
                        
                        let versions = Versions(scripts: shellSupportScriptVersion, 
                                                jitCmd: jitVersion, 
                                                jirassicCmd: jirassicVersion, 
                                                codeReview: codeReviewScriptVersion)
                        
                        let compatibility = Versioning.isCompatible(versions)
                        
                        completion(compatibility)
                    })
                })
            })
        })
    }
    
    // Not accepted in appstore apps
    /*
    func installTools (_ completion: @escaping (Bool) -> Void) {
        
        if isScriptInstalled() {
            installCmds(completion)
        } else {
            installScriptAndCmds(completion)
        }
    }
    
    func uninstallTools (_ completion: @escaping (Bool) -> Void) {
        
        if isScriptInstalled() {
            uninstallCmds({ success in
                if success {
                    
                    if let bookmark = UserDefaults.standard.object(forKey: self.shellSupportScriptName) as? NSData as Data? {
                        var stale = false
                        if let url = try? URL(resolvingBookmarkData: bookmark, options: URL.BookmarkResolutionOptions.withSecurityScope,
                                              relativeTo: nil,
                                              bookmarkDataIsStale: &stale) {
                            
                            let _ = url?.startAccessingSecurityScopedResource()
                            self.uninstallScript(atUrl: url!, completion)
                            url?.stopAccessingSecurityScopedResource()
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
    }*/
}

extension ExtensionsInteractor {
    
    fileprivate func isShellSupportInstalled() -> Bool {
        let scriptsDirectory = scripts.scriptsDirectory!
        return fileManager.fileExists(atPath: scriptsDirectory.appendingPathComponent("\(shellSupportScriptName).scpt").path)
    }
    
    fileprivate func isCodeReviewInstalled() -> Bool {
        let scriptsDirectory = scripts.scriptsDirectory!
        return fileManager.fileExists(atPath: scriptsDirectory.appendingPathComponent("\(codeReviewScriptName).scpt").path)
    }
    
    /*
    fileprivate func installScriptAndCmds (_ completion: @escaping (Bool) -> Void) {
        
        installScript(script: shellSupportScriptName, { success in
            self.installCmds(completion)
        })
    }
    
    fileprivate func installScript (script: String, _ completion: @escaping (Bool) -> Void) {
        
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(script).scpt"
        panel.directoryURL = scripts.scriptsDirectory!
        panel.message = "Please select: User / Library / Application Scripts / com.ralcr.Jirassic.osx"
        panel.level = Int(CGWindowLevelForKey(.maximumWindow))
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
                
                let scriptPath = Bundle.main.url(forResource: script, withExtension: ".scpt")
                do {
                    try? self.fileManager.copyItem(at: scriptPath!, to: panel.url!)
                    
                    let bookmark = try? panel.url!.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                                                includingResourceValuesForKeys: nil,
                                                                relativeTo: nil)
                    
                    UserDefaults.standard.set(bookmark, forKey: self.shellSupportScriptName)
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
    
    fileprivate func installCmds (_ completion: @escaping (Bool) -> Void) {
        
        let bundlePath = Bundle.main.url(forResource: "jit", withExtension: nil)!.deletingLastPathComponent()
        
        scripts.copyFile(from: bundlePath.path + "/", to: localBinPath, completion: { success in
            completion(success)
        })
    }
    
    fileprivate func uninstallCmds (_ completion: @escaping (Bool) -> Void) {
        
        scripts.removeFile(from: localBinPath, completion: { success in
            completion(success)
        })
    }
 */
}
