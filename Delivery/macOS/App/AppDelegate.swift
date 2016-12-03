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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    var activePopover: NSPopover?
    var appWireframe = AppWireframe()
    fileprivate var sleep = SleepNotifications()
	fileprivate let menu = MenuBarController()
	
    class func sharedApp() -> AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
	override init() {
		super.init()
        
        localRepository = CoreDataRepository()
//		remoteRepository = CloudKitRepository()
        
		menu.onMouseDown = { [weak self] in
			if let wself = self {
                if (wself.menu.iconView?.isSelected == true) {
                    wself.removeActivePopup()
                    wself.presentTasksPopup()
				} else {
                    wself.removeActivePopup()
				}
			}
        }
		
        sleep.computerWentToSleep = {
            self.removeActivePopup()
        }
        sleep.computerWakeUp = {
            let settings: Settings = SettingsInteractor().getAppSettings()
            if settings.showWakeUpSuggestions {
                self.presentTaskSuggestionPopup()
            } else {
                ComputerWakeUpInteractor(repository: localRepository)
                    .runWith(lastSleepDate: self.sleep.lastSleepDate)
            }
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
		
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
    
    fileprivate func presentTasksPopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.removeCurrentController()
        appWireframe.presentTasksController()
        appWireframe.showPopover(popover, fromIcon: menu.iconView!)
    }
    
    func removeActivePopup() {
        if let popover = activePopover {
            appWireframe.hidePopover(popover)
            appWireframe.removeCurrentController()
            appWireframe.removeMessage()
            activePopover = nil
        }
    }
    
    fileprivate func presentTaskSuggestionPopup() {
        let popover = NSPopover()
        activePopover = popover
        popover.contentViewController = appWireframe.appViewController
        appWireframe.presentTaskSuggestionController (startSleepDate: sleep.lastSleepDate,
                                                      endSleepDate: Date())
        appWireframe.showPopover(popover, fromIcon: menu.iconView!)
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	
    func userNotificationCenter (_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

