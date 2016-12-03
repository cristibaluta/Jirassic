//
//  AppDelegate.swift
//  Jira Logger
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import CloudKit

var localRepository: Repository!
var remoteRepository: Repository?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    let appPopover = NSPopover()
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
        
        // Add a VC to the popup
        appPopover.contentViewController = appWireframe.appViewController
        
		menu.onMouseDown = { [weak self] in
			if let wself = self {
                if (wself.menu.iconView?.isSelected == true) {
                    wself.appWireframe.presentTasksController()
					wself.appWireframe.showPopover(wself.appPopover, fromIcon: wself.menu.iconView!)
				} else {
                    wself.appWireframe.hidePopover(wself.appPopover)
                    wself.appWireframe.removeCurrentController()
                    wself.appWireframe.removeMessage()
				}
			}
        }
		
        sleep.computerWentToSleep = {
            self.appWireframe.hidePopover(self.appPopover)
        }
        sleep.computerWakeUp = {
            if true {
                self.appWireframe.presentTaskSuggestionController (startSleepDate: self.sleep.lastSleepDate,
                                                                   endSleepDate: Date())
                self.appWireframe.showPopover(self.appPopover, fromIcon: self.menu.iconView!)
            } else {
                ComputerWakeUpInteractor(repository: localRepository)
                    .runWith(lastSleepDate: self.sleep.lastSleepDate)
            }
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
		
        if let _ = remoteRepository {
            CKContainer.default().accountStatus(completionHandler: { [weak self] (accountStatus, error) in
                if accountStatus == .noAccount {
                    self?.appWireframe.presentLoginController()
                } else {
                    self?.appWireframe.presentTasksController()
                }
            })
        } else {
//            appWireframe.presentTasksController()
//            appWireframe.presentTaskSuggestionController(startSleepDate: nil, endSleepDate: Date())
        }
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
            self.appPopover.performClose(nil)
        })
    }
	
    func applicationWillTerminate (_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	
    func userNotificationCenter (_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

