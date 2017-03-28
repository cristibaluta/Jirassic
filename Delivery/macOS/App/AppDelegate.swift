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
    
    func defaultValue() -> Any {
        switch self {
        case .launchAtStartup:          return false
        case .roundDay:                 return false
        case .usePercents:              return true
        case .firstLaunch:              return true
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    var activePopover: NSPopover?
    var appWireframe = AppWireframe()
    fileprivate var sleep = SleepNotifications()
    fileprivate let menu = MenuBarController()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
	
    class func sharedApp() -> AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
	override init() {
		super.init()
        
        // For testing
        //localPreferences.reset()
        
        localRepository = SqliteRepository()
//		remoteRepository = CloudKitRepository()
        
		menu.onMouseDown = { [weak self] in
			if let wself = self {
                if (wself.menu.iconView?.isSelected == true) {
                    wself.removeActivePopup()
                    
                    let firstLaunch = wself.localPreferences.bool(.firstLaunch, version: Versioning.appVersion)
                    if firstLaunch {
                        wself.presentWelcomePopup()
                    } else {
                        wself.presentTasksPopup()
                    }
				} else {
                    wself.removeActivePopup()
				}
			}
        }
		
        sleep.computerWentToSleep = {
            self.removeActivePopup()
        }
        sleep.computerWakeUp = {
            
            guard !Date().isWeekend() else {
                return
            }
            let settings: Settings = SettingsInteractor().getAppSettings()
            
            if settings.autoTrackEnabled {
                
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
                if settings.trackingMode == .notif {
                    self.presentTaskSuggestionPopup()
                } else {
                    ComputerWakeUpInteractor(repository: localRepository)
                    .runWith(lastSleepDate: self.sleep.lastSleepDate)
                }
            }
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
        
        self.killLauncher()
        
//        if let _ = remoteRepository {
//            CKContainer.default().accountStatus(completionHandler: { [weak self] (accountStatus, error) in
//                if accountStatus == .noAccount {
//                    self?.appWireframe.presentLoginController()
//                } else {
//                    self?.appWireframe.presentTasksController()
//                }
//            })
//        } else {
//            appWireframe.presentTasksController()
//            appWireframe.presentTaskSuggestionController(startSleepDate: nil, endSleepDate: Date())
//        }
        //        let currentUser = UserInteractor(data: localRepository).currentUser()
        //		if currentUser.isLoggedIn {
        //            appWireframe?.presentTasksController()
        //		} else {
        //            appWireframe?.presentLoginController()
        //		}
        
		let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
			self.menu.iconView?.mouseDown(with: NSEvent())
		})
        NSUserNotificationCenter.default.delegate = self
        
        NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown, handler: { event in
            RCLog(event.type.rawValue)
            self.activePopover?.performClose(nil)
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
        appWireframe.showPopover(popover, fromIcon: menu.iconView!)
    }
    
    fileprivate func presentTasksPopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.removeCurrentController()
        _ = appWireframe.presentTasksController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView!)
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
        appWireframe.showPopover(popover, fromIcon: menu.iconView!)
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	
    func userNotificationCenter (_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

