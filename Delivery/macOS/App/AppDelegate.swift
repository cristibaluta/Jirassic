//
//  AppDelegate.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

var localRepository: Repository!
var remoteRepository: Repository?
let hookup = ModuleHookup()

enum LocalPreferences: String, RCPreferencesProtocol {
    
    case launchAtStartup = "launchAtStartup"
    case usePercents = "usePercents"
    case useDuration = "useDuration"
    case firstLaunch = "firstLaunch"
    case lastIcloudSync = "lastIcloudSync"
    case settingsActiveTab = "settingsActiveTab"
    case settingsJiraUrl = "settingsJiraUrl"
    case settingsJiraUser = "settingsJiraUser"
    case settingsJiraPassword = "settingsJiraPassword"
    case settingsJiraProjectId = "settingsJiraProjectId"
    case settingsJiraProjectKey = "settingsJiraProjectKey"
    case settingsJiraProjectIssueKey = "settingsJiraProjectIssueKey"
    case settingsHookupCmdName = "settingsHookupCmdName"
    case settingsGitPaths = "settingsGitPaths"
    case settingsGitAuthors = "settingsGitAuthors"
    case enableGit = "enableGit"
    case enableJira = "enableJira"
    case enableRoundingDay = "enableRoundingDay"
    case enableHookup = "enableHookup"
    case enableHookupCredentials = "enableHookupCredentials"
    
    func defaultValue() -> Any {
        switch self {
            case .launchAtStartup:          return false
            case .usePercents:              return true
            case .useDuration:              return false
            case .firstLaunch:              return true
            case .lastIcloudSync:           return Date(timeIntervalSince1970: 0)
            case .settingsActiveTab:        return SettingsTab.tracking.rawValue
            case .settingsJiraUrl:          return ""
            case .settingsJiraUser:         return ""
            case .settingsJiraPassword:     return ""
            case .settingsJiraProjectId:    return ""
            case .settingsJiraProjectKey:   return ""
            case .settingsJiraProjectIssueKey:return ""
            case .settingsHookupCmdName:    return ""
            case .settingsGitPaths:         return ""
            case .settingsGitAuthors:       return ""
            case .enableGit:                return true
            case .enableJira:               return true
            case .enableRoundingDay:        return false
            case .enableHookup:             return true
            case .enableHookupCredentials:  return true
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    var activePopover: NSPopover?
    var appWireframe = AppWireframe()
    fileprivate var sleep = SleepNotifications()
    fileprivate var browser = BrowserNotification()
    let theme = AppTheme()
    let menu = MenuBarController()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    fileprivate var animatesOpen = true
	
    class func sharedApp() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
	override init() {
		super.init()
        
        // For testing
//        localPreferences.reset()
//        UserDefaults.standard.serverChangeToken = nil
        
        localRepository = SqliteRepository()
        #if APPSTORE
        if SettingsInteractor().getAppSettings().enableBackup {
            remoteRepository = CloudKitRepository()
            remoteRepository?.getUser({ (user) in
                if user == nil {
                    remoteRepository = nil
                }
            })
        }
        #else
        RCLog("Icloud is not supported in this target, continuing without...")
        #endif
        
        menu.isDark = theme.isDark
		menu.onOpen = {
            self.removeActivePopup()
            let firstLaunch = self.localPreferences.bool(.firstLaunch, version: Versioning.appVersion)
            if firstLaunch {
                self.presentWelcomePopup()
            } else {
                self.presentTasksPopup(animated: self.animatesOpen)
                self.animatesOpen = false
            }
        }
        menu.onClose = {
            self.removeActivePopup()
        }
        
        theme.onChange = {
            self.menu.isDark = self.theme.isDark
        }
		
        sleep.computerWentToSleep = {
            self.menu.simulateClose()
            self.browser.stop()
        }
        sleep.computerWakeUp = {
            
            let isWeekend = Date().isWeekend()
            let isDayStarted = ReadTasksInteractor(repository: localRepository).tasksInDay(Date()).count > 0
            guard !isWeekend || (isDayStarted && isWeekend) else {
                RCLog(">>>>>>> It's weekend, we don't work on weekends <<<<<<<<")
                return
            }
            self.browser.start()
            let settings: Settings = SettingsInteractor().getAppSettings()
            
            if settings.settingsTracking.autotrack {
                
                let sleepDuration = Date().timeIntervalSince(self.sleep.lastSleepDate ?? Date())
                
                guard sleepDuration >= Double(settings.settingsTracking.minSleepDuration) else {
                    return
                }
                let startDate = settings.settingsTracking.startOfDayTime.dateByKeepingTime()
                guard Date() > startDate else {
                    return
                }
                
                let timeInteractor = TimeInteractor(settings: settings)
                let dayDuration = timeInteractor.workingDayLength()
                let workedDuration = timeInteractor.workedDayLength()
                guard workedDuration < dayDuration else {
                    // Do not track time exceeded the working duration
                    return
                }
                switch settings.settingsTracking.autotrackingMode {
                    case .notif:
                        self.presentTaskSuggestionPopup()
                        break
                    case .auto:
                        ComputerWakeUpInteractor(repository: localRepository)
                            .runWith(lastSleepDate: self.sleep.lastSleepDate, currentDate: Date())
                        break
                }
            }
        }
        
        browser.codeReviewDidStart = {
            RCLog("Start code review \(Date())")
        }
        browser.codeReviewDidEnd = {
            RCLog("End code review \(Date())")
            let task = Task(
                lastModifiedDate: nil,
                startDate: self.browser.startDate,
                endDate: self.browser.endDate!,
                notes: "Code review" + (self.browser.reviewedTasks.count > 1 ? " for tasks: \(self.browser.reviewedTasks.joined(separator: ", "))" : ""),
                taskNumber: "coderev",
                taskTitle: "",
                taskType: .coderev,
                objectId: String.random()
            )
            let saveInteractor = TaskInteractor(repository: localRepository)
            saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
                
            })
        }
        browser.wastingTimeDidStart = {
            RCLog("Start wasting time \(Date())")
        }
        browser.wastingTimeDidEnd = {
            RCLog("End wasting time \(Date())")
            let task = Task(
                lastModifiedDate: nil,
                startDate: self.browser.startDate,
                endDate: self.browser.endDate!,
                notes: "Wasted time",
                taskNumber: "waste",
                taskTitle: "",
                taskType: .waste,
                objectId: String.random()
            )
            let saveInteractor = TaskInteractor(repository: localRepository)
            saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
                
            })
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
        
        self.killLauncher()
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            
            if !UserDefaults.standard.bool(forKey: "launchedByLauncher") {
                self.menu.simulateOpen()
            } else {
                self.presentTaskSuggestionPopup()
            }
        })
        
        NSUserNotificationCenter.default.delegate = self
        
        NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown, handler: { event in
            self.menu.simulateClose()
        })
    }
	
    func applicationWillTerminate (_ aNotification: Notification) {
        
    }
}

extension AppDelegate {
    
    fileprivate func presentWelcomePopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.removeCurrentController()
        _ = appWireframe.presentWelcomeController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView)
    }
    
    fileprivate func presentTasksPopup (animated: Bool) {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        popover.animates = true
        appWireframe.removeCurrentController()
        _ = appWireframe.presentTasksController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView)
    }
    
    func removeActivePopup() {
        if let popover = activePopover {
            appWireframe.hidePopover(popover)
            appWireframe.removeNewTaskController()
            appWireframe.removeEndDayController()
            appWireframe.removePlaceholder()
            appWireframe.removeCurrentController()
            activePopover = nil
        }
    }
    
    fileprivate func presentTaskSuggestionPopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        _ = appWireframe.presentTaskSuggestionController (startSleepDate: sleep.lastSleepDate,
                                                          endSleepDate: Date())
        appWireframe.showPopover(popover, fromIcon: menu.iconView)
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	
    func userNotificationCenter (_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

