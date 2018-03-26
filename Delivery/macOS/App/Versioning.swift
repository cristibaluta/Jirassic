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
        "18.04.04": (shellScript: "1.0", browserScript: "1.1", jirassicCmd: "17.06.14", jitCmd: "17.06.14")
        // Add a new compatibility for each app version that needs one
    ]
    
    static func compatibilityMap (_ current: Versions) -> VersionsCompatibility {
        
        var compatibility = compatibilityMaps[appVersion]
        if compatibility == nil {
            // TODO: Get automatically the last defined version if current does not exist
            compatibility = compatibilityMaps["18.04.04"]
        }
        
        return (
            current.shellScript >= compatibility!.shellScript,
            current.browserScript >= compatibility!.browserScript,
            current.jirassicCmd >= compatibility!.jirassicCmd,
            current.jitCmd >= compatibility!.jitCmd
        )
    }
}
