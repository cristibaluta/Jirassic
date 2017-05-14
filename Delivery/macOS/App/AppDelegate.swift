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

enum LocalPreferences: String, RCPreferencesProtocol {
    
    case launchAtStartup = "launchAtStartup"
    case roundDay = "roundDay"
    case usePercents = "usePercents"
    case firstLaunch = "firstLaunch"
    case lastIcloudSync = "lastIcloudSync"
    
    func defaultValue() -> Any {
        switch self {
        case .launchAtStartup:          return false
        case .roundDay:                 return false
        case .usePercents:              return true
        case .firstLaunch:              return true
        case .lastIcloudSync:           return Date(timeIntervalSince1970: 0)
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    var activePopover: NSPopover?
    var appWireframe = AppWireframe()
    fileprivate var sleep = SleepNotifications()
    fileprivate var codeReview = CodeReviewNotification()
    let menu = MenuBarController()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
	
    class func sharedApp() -> AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
	override init() {
		super.init()
        
        // For testing
        //localPreferences.reset()
//        UserDefaults.standard.serverChangeToken = nil
        
//        localRepository = CoreDataRepository()
        localRepository = SqliteRepository()
        if SettingsInteractor().getAppSettings().enableBackup {
            remoteRepository = CloudKitRepository()
        }
        
		menu.onOpen = {
            self.removeActivePopup()
            let firstLaunch = self.localPreferences.bool(.firstLaunch, version: Versioning.appVersion)
            if firstLaunch {
                self.presentWelcomePopup()
            } else {
                self.presentTasksPopup()
            }
        }
        menu.onClose = {
            self.removeActivePopup()
        }
		
        sleep.computerWentToSleep = {
            self.menu.simulateClose()
            self.codeReview.stop()
        }
        sleep.computerWakeUp = {
            
            guard !Date().isWeekend() else {
                RCLog(">>>>>>> It's weekend, we don't work on weekends <<<<<<<<")
                return
            }
            self.codeReview.start()
            let settings: Settings = SettingsInteractor().getAppSettings()
            
            if settings.autotrack {
                
                let sleepDuration = Date().timeIntervalSince(self.sleep.lastSleepDate ?? Date())
                let minSleepDuration = Double(settings.minSleepDuration.components().minute).minToSec +
                                       Double(settings.minSleepDuration.components().hour).hoursToSec
                
                guard sleepDuration >= minSleepDuration else {
                    return
                }
                let startDate = settings.startOfDayTime.dateByKeepingTime()
                guard Date() > startDate else {
                    return
                }
                
                let dayDuration = settings.endOfDayTime.timeIntervalSince(settings.startOfDayTime)
                let workedDuration = Date().timeIntervalSince( settings.startOfDayTime.dateByKeepingTime())
                guard workedDuration < dayDuration else {
                    // Do not track time exceeded the working duration
                    return
                }
                switch settings.autotrackingMode {
                case .notif:
                    self.presentTaskSuggestionPopup()
                    break
                case .auto:
                    ComputerWakeUpInteractor(repository: localRepository).runWith(lastSleepDate: self.sleep.lastSleepDate)
                    break
                }
            }
        }
        
        codeReview.codeReviewDidStart = {
            RCLog("Start code review \(Date())")
        }
        codeReview.codeReviewDidEnd = {
            RCLog("End code review \(Date())")
            let task = Task(
                lastModifiedDate: nil,
                startDate: self.codeReview.startDate,
                endDate: self.codeReview.endDate!,
                notes: "Code review" + (self.codeReview.reviewedTasks.count > 1 ? " for tasks: \(self.codeReview.reviewedTasks.joined(separator: ", "))" : ""),
                taskNumber: "coderev",
                taskTitle: "",
                taskType: .coderev,
                objectId: String.random()
            )
            let saveInteractor = TaskInteractor(repository: localRepository)
            saveInteractor.saveTask(task, completion: { savedTask in
                saveInteractor.syncTask(savedTask, completion: { (task) in })
            })
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
        
        self.killLauncher()
        
        //        let currentUser = UserInteractor(data: localRepository).currentUser()
        //		if currentUser.isLoggedIn {
        //            appWireframe?.presentTasksController()
        //		} else {
        //            appWireframe?.presentLoginController()
        //		}
        
		let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
			self.menu.simulateOpen()
		})
        NSUserNotificationCenter.default.delegate = self
        
        NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown, handler: { event in
            self.menu.simulateClose()
        })
    }
	
    func applicationWillTerminate (_ aNotification: Notification) {
        // Insert code here to tear down your application
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
    
    fileprivate func presentTasksPopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        popover.animates = false
        appWireframe.removeCurrentController()
        _ = appWireframe.presentTasksController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView)
    }
    
    func removeActivePopup() {
        if let popover = activePopover {
            appWireframe.hidePopover(popover)
            appWireframe.removeNewTaskController()
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

