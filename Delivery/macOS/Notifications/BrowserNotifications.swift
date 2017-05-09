//
//  BrowserNotifications.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class BrowserNotifications {
    
    var browserIsFrontmostApplication: ((_ url: String, _ title: String) -> ())?
    fileprivate var timer: Timer?
    fileprivate var extensionsInteractor = ExtensionsInteractor()
    
    init() {
        let delay = 10.0
        timer = Timer.scheduledTimer(timeInterval: delay,
                                     target: self,
                                     selector: #selector(handleTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func handleTimer (timer: Timer) {
        
        let app: NSRunningApplication = NSWorkspace.shared().frontmostApplication!
        let appId = app.bundleIdentifier!
//        let appId = "com.apple.Safari"
        RCLogO(appId)
        
        guard appId == "com.apple.Safari" || appId == "com.google.Chrome" else {
            return
        }
        
        extensionsInteractor.getBrowserInfo(browserId: appId, completion: { (url, title) in
            RCLog(url)
            RCLog(title)
            self.browserIsFrontmostApplication?(url, title)
        })
    }
}
