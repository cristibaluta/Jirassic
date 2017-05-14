//
//  Versioning.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

typealias Versions = (shellScript: String, browserScript: String, jirassicCmd: String, jitCmd: String)
typealias VersionsCompatibility = (shellScript: Bool, browserScript: Bool, jirassicCmd: Bool, jitCmd: Bool)

struct Versioning {
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let compatibilityDict: [String: Versions] = [
        "17.05.31": (shellScript: "1.0", browserScript: "1.0", jirassicCmd: "17.05.31", jitCmd: "17.05.06")
        // Add a new compatibility for each app version
    ]
    
    static func isCompatible (_ current: Versions) -> VersionsCompatibility {
        
        var compatibility = compatibilityDict[appVersion]
        if compatibility == nil {
            // TODO: Get automatically the last defined version if current does not exist
            compatibility = compatibilityDict["17.05.31"]
        }
        
        return (
            current.shellScript >= compatibility!.shellScript,
            current.browserScript >= compatibility!.browserScript,
            current.jirassicCmd >= compatibility!.jirassicCmd,
            current.jitCmd >= compatibility!.jitCmd
        )
    }
}
