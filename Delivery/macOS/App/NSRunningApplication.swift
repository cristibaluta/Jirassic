//
//  NSRunningExtension.swift
//  Jirassic
//
//  Created by Cristian Baluta on 08/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

extension NSRunningApplication {
    
    var activeTabURL: NSURL?{
        guard self.isActive, let bundleIdentifier = self.bundleIdentifier else {
            return nil
        }
        
        let code: String? = {
            switch(bundleIdentifier){
            case "org.chromium.Chromium":
                return "tell application \"Chromium\" to return URL of active tab of front window"
            case "com.google.Chrome.canary":
                return "tell application \"Google Chrome Canary\" to return URL of active tab of front window"
            case "com.google.Chrome":
                return "tell application \"Google Chrome\" to return URL of active tab of front window"
            case "com.apple.Safari":
                return "tell application \"Safari\" to return URL of front document"
            default:
                return nil
            }
        }()
        
        var errorInfo: NSDictionary?
        if let code = code, let script = NSAppleScript(source: code), let out: NSAppleEventDescriptor = script.executeAndReturnError(&errorInfo){
            if let errorInfo = errorInfo{
                print(errorInfo)
                
            } else if let urlString = out.stringValue{
                return NSURL(string: urlString)
            }
        }
        
        return nil
    }
    
    
    var activeTabTitle: String?{
        guard self.isActive, let bundleIdentifier = self.bundleIdentifier else {
            return nil
        }
        
        let code: String? = {
            switch(bundleIdentifier){
            case "org.chromium.Chromium":
                return "tell application \"Chromium\" to return title of active tab of front window"
            case "com.google.Chrome.canary":
                return "tell application \"Google Chrome Canary\" to return title of active tab of front window"
            case "com.google.Chrome":
                return "tell application \"Google Chrome\" to return title of active tab of front window"
            case "com.apple.Safari":
                return "tell application \"Safari\" to return name of front document"
            default:
                return nil
            }
        }()
        
        var errorInfo: NSDictionary?
        if let code = code, let script = NSAppleScript(source: code), let out: NSAppleEventDescriptor = script.executeAndReturnError(&errorInfo){
            if let errorInfo = errorInfo{
                print(errorInfo)
                
            } else {
                return out.stringValue
            }
        }
        
        return nil
    }
}
