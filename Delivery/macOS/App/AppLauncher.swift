//
//  AppLauncher.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

let launcherIdentifier = "com.jirassic.macos.launcher"

extension AppDelegate {

//    func launchAtStartup() {
//        
//        guard InternalSettings().launchAtStartup else {
//            return
//        }
//        InternalSettings().launchAtStartup = true
//        killLauncher()
//    }
    
    func killLauncher() {
        
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleIdentifier == launcherIdentifier {
                DistributedNotificationCenter.default()
                    .postNotificationName(NSNotification.Name(rawValue: "killme"),
                                          object: Bundle.main.bundleIdentifier!,
                                          userInfo: nil,
                                          deliverImmediately: true)
                break
            }
        }
    }
}
