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
        #if ICLOUD
            scripts = SandboxedAppleScript()
        #else
            scripts = AppleScriptInteractor()
        #endif
    }
    
    func getJiraSettings (completion: @escaping ([String: String]) -> Void) {
        
        scripts.getJitInfo(completion: { dict in
            completion(dict)
        })
    }
    
    func getBrowserInfo (browserId: String, completion: @escaping (String, String) -> Void) {
        scripts.getBrowserInfo(browserId: browserId, completion: completion)
    }
    
    func getVersions (completion: @escaping (_ versions: Versions) -> Void) {
        
        self.scripts.getScriptVersion (script: kShellSupportScriptName, completion: { shellSupportScriptVersion in
        self.scripts.getScriptVersion (script: kBrowserSupportScriptName, completion: { browserSupportScriptVersion in
        self.scripts.getJirassicVersion (completion: { jirassicVersion in
        self.scripts.getJitInfo (completion: { dict in
            
            let jitVersion = dict["version"] ?? ""
            let versions = Versions(shellScript: shellSupportScriptVersion, 
                                    browserScript: browserSupportScriptVersion,
                                    jitCmd: jitVersion, 
                                    jirassicCmd: jirassicVersion
            )
            completion(versions)
        })
        })
        })
        })
    }
}
