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
    static let compatibilityMaps: [String: Versions] = [
        "17.06.14": (shellScript: "1.0", browserScript: "1.0", jirassicCmd: "17.06.14", jitCmd: "17.06.14"),
        "18.04.04": (shellScript: "1.0", browserScript: "1.1", jirassicCmd: "17.06.14", jitCmd: "17.06.14"),
        "18.04.25": (shellScript: "1.0", browserScript: "1.1", jirassicCmd: "18.04.25", jitCmd: "18.04.25")
        // Add a new compatibility for each app version that needs one
    ]
    
    static func compatibilityMap (_ current: Versions) -> VersionsCompatibility {
        
        var compatibility = compatibilityMaps[appVersion]
        if compatibility == nil {
            let sortedKeys = compatibilityMaps.keys.sorted()
            let lastKey = sortedKeys.last!
            compatibility = compatibilityMaps[lastKey]
        }
        
        return (
            current.shellScript >= compatibility!.shellScript,
            current.browserScript >= compatibility!.browserScript,
            current.jirassicCmd >= compatibility!.jirassicCmd,
            current.jitCmd >= compatibility!.jitCmd
        )
    }
}
