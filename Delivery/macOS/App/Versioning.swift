//
//  Versioning.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

typealias Versions = (scripts: String, jitCmd: String, jirassicCmd: String)

struct Versioning {
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let compatibilityDict: [String: Versions] = [
        "17.02.28": (scripts: "1.0", jitCmd: "17.02.09", jirassicCmd: "17.02.28")
        // Add a new compatibility for each version
    ]
    
    static func isCompatibleWithTools (_ tools: Versions) -> Bool {
        
        var versions = compatibilityDict[appVersion]
        if versions == nil {
            // TODO: Get the last version if current does not exist
            versions = compatibilityDict["17.02.28"]
        }
        
        return 
            tools.scripts >= versions!.scripts && 
            tools.jitCmd >= versions!.jitCmd && 
            tools.jirassicCmd >= versions!.jirassicCmd
    }
}
