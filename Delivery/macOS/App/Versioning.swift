//
//  Versioning.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

typealias Versions = (shellScript: String, browserScript: String, jirassicCmd: String, jitCmd: String)
typealias Compatibility = (currentVersion: String, minVersion: String, available: Bool, compatible: Bool)

class Versioning {
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    private let compatibilityMaps: [String: Versions] = [
        "17.06.14": (shellScript: "1.0", browserScript: "1.0", jirassicCmd: "17.06.14", jitCmd: "17.06.14"),
        "18.04.04": (shellScript: "1.0", browserScript: "1.1", jirassicCmd: "17.06.14", jitCmd: "17.06.14"),
        "18.04.25": (shellScript: "1.0", browserScript: "1.1", jirassicCmd: "18.04.25", jitCmd: "18.04.25"),
        "18.12.12": (shellScript: "1.0", browserScript: "1.1", jirassicCmd: "18.12.12", jitCmd: "18.12.12")
        // Add a new compatibility for each app version that needs one
    ]
    private let versions: Versions
    private let minVersions: Versions
    
    var shellScript: Compatibility {
        return (currentVersion: versions.shellScript,
                minVersion: minVersions.shellScript,
                available: versions.shellScript != "",
                compatible: versions.shellScript >= minVersions.shellScript)
    }
    var jirassic: Compatibility {
        return (currentVersion: versions.jirassicCmd,
                minVersion: minVersions.jirassicCmd,
                available: versions.jirassicCmd != "",
                compatible: versions.jirassicCmd >= minVersions.jirassicCmd)
    }
    var jit: Compatibility {
        return (currentVersion: versions.jitCmd,
                minVersion: minVersions.jitCmd,
                available: versions.jitCmd != "",
                compatible: versions.jitCmd >= minVersions.jitCmd)
    }
    var browser: Compatibility {
        return (currentVersion: versions.browserScript,
                minVersion: minVersions.browserScript,
                available: versions.browserScript != "",
                compatible: versions.browserScript >= minVersions.browserScript)
    }
    
    init (versions: Versions) {
        self.versions = versions
        // Find the current compatibility map
        var currentCompatibilityMap = compatibilityMaps[Versioning.appVersion]
        if currentCompatibilityMap == nil {
            let sortedKeys = compatibilityMaps.keys.sorted()
            let lastKey = sortedKeys.last!
            currentCompatibilityMap = compatibilityMaps[lastKey]
        }
        self.minVersions = currentCompatibilityMap!
    }
}
