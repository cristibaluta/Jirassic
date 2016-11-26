//
//  AppDelegate.swift
//  Jira Logger
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
    @IBOutlet var popover: NSPopover?
    var appWireframe = AppWireframe()
    fileprivate var sleep: SleepNotifications?
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
					wself.appWireframe.showPopover(wself.popover!, fromIcon: wself.menu.iconView!)
				} else {
					wself.appWireframe.hidePopover(wself.popover!)
				}
			}
        }
		
        sleep = SleepNotifications()
        sleep?.computerWentToSleep = {
			// Nothing to do
        }
        sleep?.computerWakeUp = {
			ComputerWakeUpInteractor(repository: localRepository).runWithLastSleepDate(self.sleep?.lastSleepDate)
        }
	}
	
    func applicationDidFinishLaunching (_ aNotification: Notification) {
		
		let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
		DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
			self.menu.iconView?.mouseDown(with: NSEvent())
		})
        NSUserNotificationCenter.default.delegate = self
        
        NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown, handler: { event in
            self.popover?.performClose(nil)
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

