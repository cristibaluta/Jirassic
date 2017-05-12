//
//  Versioning.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

typealias Versions = (scripts: String, jitCmd: String, jirassicCmd: String, codeReview: String)
typealias VersionsCompatibility = (scripts: Bool, jitCmd: Bool, jirassicCmd: Bool, codeReview: Bool)

struct Versioning {
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let compatibilityDict: [String: Versions] = [
        "17.05.31": (scripts: "1.0", jitCmd: "17.02.09", jirassicCmd: "17.02.28", codeReview: "1.0")
        // Add a new compatibility for each app version
    ]
    
    static func isCompatible (_ tools: Versions) -> VersionsCompatibility {
        
        var versions = compatibilityDict[appVersion]
        if versions == nil {
            // TODO: Get automatically the last defined version if current does not exist
            versions = compatibilityDict["17.05.31"]
        }
        
        return (
            tools.scripts >= versions!.scripts,
            tools.jitCmd >= versions!.jitCmd,
            tools.jirassicCmd >= versions!.jirassicCmd,
            tools.codeReview >= versions!.codeReview
        )
    }
}
