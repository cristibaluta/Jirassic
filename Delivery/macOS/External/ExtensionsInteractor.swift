//
//  CMDToolsInstaller.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

let kShellSupportScriptName = "ShellSupport"
let kBrowserSupportScriptName = "BrowserSupport"
let kLocalBinPath = "/usr/local/bin/"

class ExtensionsInteractor {
    
    fileprivate let scripts: AppleScriptProtocol!
    
    init() {
        #if APPSTORE
            scripts = SandboxedAppleScript()
        #else
            scripts = AppleScript()
        #endif
    }
    
    func getJiraSettings (completion: @escaping ([String: String]) -> Void) {
        
        scripts.getJitInfo(completion: { dict in
            completion(dict)
        })
    }
    
    func getBrowserInfo (browserId: String, browserName: String, completion: @escaping (String, String) -> Void) {
        scripts.getBrowserInfo(browserId: browserId, browserName: browserName, completion: completion)
    }
    
    func run (command: String, completion: @escaping (String?) -> Void) {
        scripts.run(command: command, completion: completion)
    }
    
    func getShellScriptVersion (completion: @escaping (String) -> Void) {
        scripts.getScriptVersion(script: kShellSupportScriptName) { version in
            completion(version)
        }
    }
    func getBrowserScriptVersion (completion: @escaping (String) -> Void) {
        scripts.getScriptVersion(script: kBrowserSupportScriptName) { version in
            completion(version)
        }
    }
    func getJirassicCliVersion (completion: @escaping (String) -> Void) {
        scripts.getJirassicVersion() { version in
            completion(version)
        }
    }
    func getJitCliVersion (completion: @escaping (String) -> Void) {
        scripts.getJitInfo() { dict in
            let version = dict["version"] ?? ""
            completion(version)
        }
    }

    func getAllVersions (completion: @escaping (_ versions: Versions) -> Void) {

        self.getShellScriptVersion() { shellSupportScriptVersion in
        self.getBrowserScriptVersion() { browserSupportScriptVersion in
        self.getJirassicCliVersion() { jirassicCliVersion in
        self.getJitCliVersion() { jitCliVersion in

            completion(
                Versions(shellScript: shellSupportScriptVersion,
                         browserScript: browserSupportScriptVersion,
                         jirassicCmd: jirassicCliVersion,
                         jitCmd: jitCliVersion)
            )
        }
        }
        }
        }
    }
}
