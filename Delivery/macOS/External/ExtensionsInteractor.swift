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
    
    func getVersions (completion: @escaping (_ versions: Versions) -> Void) {
        
        self.scripts.getScriptVersion (script: kShellSupportScriptName, completion: { shellSupportScriptVersion in
        self.scripts.getScriptVersion (script: kBrowserSupportScriptName, completion: { browserSupportScriptVersion in
        self.scripts.getJirassicVersion (completion: { jirassicCliVersion in
        self.scripts.getJitInfo (completion: { jitCliDict in

            let jitCliVersion = jitCliDict["version"] ?? ""
            let versions = Versions(shellScript: shellSupportScriptVersion,
                                    browserScript: browserSupportScriptVersion,
                                    jirassicCmd: jirassicCliVersion,
                                    jitCmd: jitCliVersion
            )
            completion(versions)
        })
        })
        })
        })
    }
}
