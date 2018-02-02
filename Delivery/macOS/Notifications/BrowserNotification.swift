//
//  BrowserNotifications.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class BrowserNotification {
    
    var codeReviewDidStart: (() -> Void)?
    var codeReviewDidEnd: (() -> Void)?
    var wastingTimeDidStart: (() -> Void)?
    var wastingTimeDidEnd: (() -> Void)?
    
    var startDate: Date?
    var endDate: Date?
    var reviewedTasks = [String]()
    var taskType: TaskType?
    
    fileprivate let delay = 15.0
    fileprivate let stashUrlEreg = "(http|https)://(.+)/projects/(.+)/repos/(.+)/pull-requests"
    fileprivate let taskIdEreg = "([A-Z]+-[0-9])\\w+"
    fileprivate let browsersIds = ["com.apple.Safari", "com.google.Chrome"]
    fileprivate var timer: Timer?
    fileprivate var extensionsInteractor = ExtensionsInteractor()
    fileprivate var reader: ReadTasksInteractor?
    
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
        
        let app: NSRunningApplication = NSWorkspace.shared.frontmostApplication!
        let appId = app.bundleIdentifier!
//        RCLogO(appId)
        
        guard browsersIds.contains(appId) else {
            if let taskType = self.taskType {
                switch taskType {
                case .waste:
                    handleWastingTimeEnd()
                    break
                case .coderev:
                    handleCodeRevEnd()
                    break
                default:
                    break
                }
            }
            return
        }
        
        reader = ReadTasksInteractor(repository: localRepository)
        let existingTasks = reader!.tasksInDay(Date())
        
        guard let startDay = existingTasks.first else {
            return
        }
        let settings: Settings = SettingsInteractor().getAppSettings()
        let maxDuration = settings.settingsTracking.endOfDayTime.timeIntervalSince(settings.settingsTracking.startOfDayTime)
        let workedDuration = Date().timeIntervalSince( startDay.endDate )
        guard workedDuration < maxDuration else {
            // Do not track browser events past working duration
            return
        }
        
        extensionsInteractor.getBrowserInfo(browserId: appId, completion: { (url, title) in
            
            RCLog(url)
//            RCLog(title)
            
            if self.isCodeRevLink(url) {
                if self.isWastingTime() {
                    self.handleWastingTimeEnd()
                }
                if !self.isInCodeRev() {
                    self.handleCodeRevStart()
                }
                // Store the task you are reviewing
                let regex = try! NSRegularExpression(pattern: self.taskIdEreg, options: [])
                let match = regex.firstMatch(in: title, options: [], range: NSRange(location: 0, length: title.count))
                if let match = match {
                    let taskNumber = (title as NSString).substring(with: match.range)
                    if !self.reviewedTasks.contains(taskNumber) {
                        self.reviewedTasks.append(taskNumber)
                    }
                }
            }
            else if self.isWastingTimeLink(url) {
                if self.isInCodeRev() {
                    self.handleCodeRevEnd()
                }
                if !self.isWastingTime() {
                    self.handleWastingTimeStart()
                }
            }
            else {
                if self.isInCodeRev() {
                    self.handleCodeRevEnd()
                }
                if self.isWastingTime() {
                    self.handleWastingTimeEnd()
                }
            }
        })
    }
}

extension BrowserNotification {
    
    fileprivate func handleCodeRevStart() {
        
        guard !isInCodeRev() else {
            return
        }
        taskType = .coderev
        startDate = Date()
        reviewedTasks = [String]()
        codeReviewDidStart?()
    }
    
    fileprivate func handleCodeRevEnd() {
        
        guard isInCodeRev() else {
            return
        }
        self.endDate = Date()
        let settings = localRepository.settings()
        let duration = self.endDate!.timeIntervalSince(startDate!)
        if duration >= Double(settings.settingsBrowser.minCodeRevDuration).minToSec {
            self.codeReviewDidEnd?()
        } else {
            RCLog("Discard code review session with duration \(duration) < \(Double(settings.settingsBrowser.minCodeRevDuration).minToSec)")
        }
        startDate = nil
    }
    
    fileprivate func isCodeRevLink (_ url: String) -> Bool {
        
        let settings = localRepository.settings()
        let coderevLink = settings.settingsBrowser.codeRevLink != "" ? settings.settingsBrowser.codeRevLink : self.stashUrlEreg
        let coderevRegex = try! NSRegularExpression(pattern: coderevLink, options: [])
        let matches = coderevRegex.matches(in: url, options: [], range: NSRange(location: 0, length: url.count))
        
        return matches.count > 0
    }
    
    fileprivate func isInCodeRev() -> Bool {
        return startDate != nil && taskType == .coderev
    }
}

extension BrowserNotification {
    
    fileprivate func handleWastingTimeStart() {
        
        guard !isWastingTime() else {
            return
        }
        taskType = .waste
        startDate = Date()
        wastingTimeDidStart?()
    }
    
    fileprivate func handleWastingTimeEnd() {
        
        guard isWastingTime() else {
            return
        }
        self.endDate = Date()
        let settings: Settings = SettingsInteractor().getAppSettings()
        let duration = self.endDate!.timeIntervalSince(startDate!)
        if duration >= Double(settings.settingsBrowser.minWasteDuration).minToSec {
            self.wastingTimeDidEnd?()
        } else {
            RCLog("Discard wasting time session with duration \(duration) < \(Double(settings.settingsBrowser.minWasteDuration).minToSec)")
        }
        startDate = nil
    }
    
    fileprivate func isWastingTimeLink (_ url: String) -> Bool {
        
        let settings = localRepository.settings()
        for link in settings.settingsBrowser.wasteLinks {
            guard link != "" else {
                continue
            }
            let regex = try! NSRegularExpression(pattern: link, options: [])
            let matches = regex.matches(in: url, options: [], range: NSRange(location: 0, length: url.count))
            if matches.count > 0 {
                return true
            }
        }
        return false
    }
    
    fileprivate func isWastingTime() -> Bool {
        return startDate != nil && taskType == .waste
    }
}
