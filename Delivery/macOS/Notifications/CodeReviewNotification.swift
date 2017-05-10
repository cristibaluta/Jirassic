//
//  BrowserNotifications.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class CodeReviewNotification {
    
    var codeReviewDidStart: (() -> Void)?
    var codeReviewDidEnd: (() -> Void)?
    var startDate: Date?
    var endDate: Date?
    var tasksNumbers = [String]()
    
    fileprivate let delay = 10.0
    fileprivate let minCodeRedDuration = 10.0
    fileprivate let stashUrlEreg = "(http|https)://(.+)/projects/(.+)/repos/(.+)/pull-requests"
    fileprivate let taskIdEreg = "([A-Z]+-[0-9])\\w+"
    fileprivate var timer: Timer?
    fileprivate var extensionsInteractor = ExtensionsInteractor()
    
    init() {
        start()
    }
    
    func start() {
        stop()
        timer = Timer.scheduledTimer(timeInterval: delay,
                                     target: self,
                                     selector: #selector(handleTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func handleTimer (timer: Timer) {
        
        let app: NSRunningApplication = NSWorkspace.shared().frontmostApplication!
        let appId = app.bundleIdentifier!
//        RCLogO(appId)
        
        guard appId == "com.apple.Safari" || appId == "com.google.Chrome" else {
            handleCodeRevEnd()
            return
        }
        
        extensionsInteractor.getBrowserInfo(browserId: appId, completion: { (url, title) in
            
//            RCLog(url)
//            RCLog(title)
            
            let regex = try! NSRegularExpression(pattern: self.stashUrlEreg, options: [])
            let matches = regex.matches(in: url, options: [], range: NSRange(location: 0, length: url.characters.count))
            
            if matches.count > 0 && self.isInCodeRev() {
                let regex = try! NSRegularExpression(pattern: self.taskIdEreg, options: [])
                let match = regex.firstMatch(in: title, options: [], range: NSRange(location: 0, length: title.characters.count))
                if let match = match {
                    let taskNumber = (title as NSString).substring(with: match.range)
                    if !self.tasksNumbers.contains(taskNumber) {
                        self.tasksNumbers.append(taskNumber)
                    }
                }
            }
            if matches.count > 0 {
                self.handleCodeRevStart()
            } else {
                self.handleCodeRevEnd()
            }
        })
    }
    
    fileprivate func handleCodeRevStart() {
        
        guard !isInCodeRev() else {
            return
        }
        startDate = Date()
        tasksNumbers = [String]()
        codeReviewDidStart?()
    }
    
    fileprivate func handleCodeRevEnd() {
        
        guard isInCodeRev() else {
            return
        }
        self.endDate = Date()
        let duration = self.endDate!.timeIntervalSince(startDate!)
        if duration >= minCodeRedDuration {
            self.codeReviewDidEnd?()
        }
        startDate = nil
    }
    
    fileprivate func isInCodeRev() -> Bool {
        return startDate != nil
    }
}
