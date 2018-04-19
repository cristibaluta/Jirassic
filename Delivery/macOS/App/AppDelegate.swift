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
    case wizardStep = "wizardStep"
    case settingsActiveTab = "settingsActiveTab"
    case settingsJiraUrl = "settingsJiraUrl"
    case settingsJiraUser = "settingsJiraUser"
    case settingsJiraProjectId = "settingsJiraProjectId"
    case settingsJiraProjectKey = "settingsJiraProjectKey"
    case settingsJiraProjectIssueKey = "settingsJiraProjectIssueKey"
    case settingsHookupCmdName = "settingsHookupCmdName"
    case settingsHookupAppName = "settingsHookupAppName"
    case settingsGitPaths = "settingsGitPaths"
    case settingsGitAuthors = "settingsGitAuthors"
    case enableGit = "enableGit"
    case enableJira = "enableJira"
    case enableRoundingDay = "enableRoundingDay"
    case enableHookup = "enableHookup"
    case enableCocoaHookup = "enableCocoaHookup"
    case enableHookupCredentials = "enableHookupCredentials"
    
    func defaultValue() -> Any {
        switch self {
            case .launchAtStartup:          return false
            case .usePercents:              return true
            case .useDuration:              return false
            case .firstLaunch:              return true
            case .wizardStep:               return WizardStep.shell.rawValue
            case .settingsActiveTab:        return SettingsTab.tracking.rawValue
            case .settingsJiraUrl:          return ""
            case .settingsJiraUser:         return ""
            case .settingsJiraProjectId:    return ""
            case .settingsJiraProjectKey:   return ""
            case .settingsJiraProjectIssueKey:return ""
            case .settingsHookupCmdName:    return ""
            case .settingsHookupAppName:    return ""
            case .settingsGitPaths:         return ""
            case .settingsGitAuthors:       return ""
            case .enableGit:                return false
            case .enableJira:               return true
            case .enableRoundingDay:        return false
            case .enableHookup:             return false
            case .enableCocoaHookup:        return false
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
        localPreferences.reset(.wizardStep)
        localPreferences.set(2, forKey: .wizardStep)
        
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
            let wizardStep = self.localPreferences.int(.wizardStep)
            if firstLaunch {
                self.presentWelcomePopup()
            }
            else if wizardStep != WizardStep.finished.rawValue {
                self.presentWizard()
            }
            else {
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
            self.menu.triggerClose()
            self.browser.stop()
        }
        sleep.computerWakeUp = {
            
            let tasks = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
                        .tasksInDay(Date())
            let isWeekend = Date().isWeekend()
            let isDayStarted = tasks.count > 0
            let isDayEnded = tasks.contains(where: { $0.taskType == .endDay })
            guard !isWeekend || (isDayStarted && isWeekend) else {
                RCLog(">>>>>>> It's weekend, won't track weekends <<<<<<<<")
                return
            }
            guard !isDayEnded else {
                RCLog(">>>>>>> Day ended, won't analyze further <<<<<<<<")
                return
            }
            self.browser.start()
            let settings: Settings = SettingsInteractor().getAppSettings()
            guard settings.settingsTracking.autotrack else {
                RCLog(">>>>>>> Autotracking disabled, won't present suggestions to user <<<<<<<<")
                return
            }
            
            let sleepDuration = Date().timeIntervalSince(self.sleep.lastSleepDate ?? Date())
            guard sleepDuration >= Double(settings.settingsTracking.minSleepDuration) else {
                RCLog(">>>>>>> Sleep duration is shorter than the minimum required \(sleepDuration) >= \(Double(settings.settingsTracking.minSleepDuration)) <<<<<<<<")
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
                    self.removeActivePopup()
                    self.presentTaskSuggestionPopup()
                    break
                case .auto:
                    ComputerWakeUpInteractor(repository: localRepository, remoteRepository: remoteRepository, settings: settings)
                        .runWith(lastSleepDate: self.sleep.lastSleepDate, currentDate: Date())
                    break
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
            let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
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
                notes: TaskSubtype.wasteEnd.defaultNotes,
                taskNumber: TaskSubtype.wasteEnd.defaultTaskNumber,
                taskTitle: "",
                taskType: .waste,
                objectId: String.random()
            )
            let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
            saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
                
            })
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
        
        self.killLauncher()
        
        // Open with a delay because the popup doesn't play well otherwise
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            
            if !UserDefaults.standard.bool(forKey: "launchedByLauncher") {
                self.menu.triggerOpen()
            } else {
                self.presentTaskSuggestionPopup()
            }
        })
        
        NSUserNotificationCenter.default.delegate = self
        
        NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown, handler: { event in
            self.menu.triggerClose()
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
    
    fileprivate func presentWizard() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.removeCurrentController()
        _ = appWireframe.presentWizardController()
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

