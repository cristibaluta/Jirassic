//
//  AppDelegate.swift
//  JirassicLauncher
//
//  Created by Cristian Baluta on 23/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let identifier = "com.ralcr.Jirassic.osx"
        
        var alreadyRunning = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == identifier {
                alreadyRunning = true
                break
            }
        }
        if !alreadyRunning {
            DistributedNotificationCenter.default()
                .addObserver(self,
                             selector: #selector(AppDelegate.terminate),
                             name: NSNotification.Name(rawValue: "killme"),
                             object: identifier)
            
            let path = Bundle.main.bundlePath as NSString
            print(path)
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("Jirassic")
            
            let newPath = NSString.path(withComponents: components)
            print(newPath)
            NSWorkspace.shared().launchApplication(newPath)
        } else {
            terminate()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func terminate() {
        NSApp.terminate(nil)
    }
}
