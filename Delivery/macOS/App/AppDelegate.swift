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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    var activePopover: NSPopover?
    let appWireframe = AppWireframe()
    let sleep = SleepNotifications()
    private let browser = BrowserNotification()
    let theme = AppTheme()
    let menu = MenuBarController()
    private let localPreferences = RCPreferences<LocalPreferences>()
    private var animatesOpen = true
	
    class func sharedApp() -> AppDelegate {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
	override init() {
		super.init()
        
        #if DEBUG
        // Simulate a freshly installed app by resetting the preferences
//        localPreferences.reset()
//        UserDefaults.standard.serverChangeToken = nil
        localPreferences.reset(.wizardSteps)
        localPreferences.set(true, forKey: .firstLaunch, version: Versioning.appVersion)
//        localPreferences.set(0, forKey: .wizardStep)
//        localPreferences.set(false, forKey: .enableGit)
        #endif
        
        self.window?.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        
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
//        _ = Store.shared
        #else
        RCLog("Icloud is not supported in this target, continuing without...")
        #endif
        
        menu.isDark = theme.isDark
		menu.onOpen = {
            self.removeActivePopup()
            let isFirstLaunch = self.localPreferences.bool(.firstLaunch, version: Versioning.appVersion)
            let wizardSteps: [Int] = self.localPreferences.get(.wizardSteps)
            if isFirstLaunch {
                self.presentWelcomePopup()
            }
            else if wizardSteps.count < WizardStep.allCases.count {
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
                RCLog(">>>>>>> It's weekend, won't track weekends unless the day was started <<<<<<<<")
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
            guard sleepDuration >= Double(settings.settingsTracking.minSleepDuration).minToSec else {
                RCLog(">>>>>>> Sleep duration is shorter than the minimum required: \(sleepDuration) < \(Double(settings.settingsTracking.minSleepDuration).minToSec) <<<<<<<<")
                return
            }
            let startDate = settings.settingsTracking.startOfDayTime.dateByKeepingTime()
            guard Date() > startDate else {
                RCLog(">>>>>>> Woke up earlier than the predefined startDay, won't analyze further <<<<<<<<")
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
                notes: self.browser.reviewedTasks.joined(separator: ", "),
                taskNumber: nil,
                taskTitle: nil,
                taskType: .coderev,
                objectId: String.generateId()
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
                notes: nil,
                taskNumber: TaskType.waste.defaultTaskNumber,
                taskTitle: "",
                taskType: .waste,
                objectId: String.generateId()
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
    
    private func presentWelcomePopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.removeCurrentController()
        _ = appWireframe.presentWelcomeController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView)
    }
    
    private func presentWizard() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.removeCurrentController()
        _ = appWireframe.presentWizardController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView)
    }
    
    private func presentTasksPopup (animated: Bool) {
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
            activePopover = nil
            appWireframe.hidePopover(popover)
            appWireframe.removeEndDayController()
            appWireframe.removePlaceholder()
            appWireframe.removeCurrentController()
        }
    }
    
    private func presentTaskSuggestionPopup() {
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

