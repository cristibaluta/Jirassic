//
//  AppDelegate.swift
//  Jira Logger
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import ParseOSX

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow?
    @IBOutlet var statusMenu: NSMenu?
    var statusItem: NSStatusItem?
	var menubarController: MenuBarController?
	var panelController: PanelController?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
		
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/OSX
		
		JiraData.registerSubclass()
		
        Parse.enableLocalDatastore()
        Parse.setApplicationId("DFWPmEOCnRCody7tfeXjzNZAl6nKCaTZELWSEeyZ",
			clientKey:"WdjHVrrPJexhd4nnFZyOx9GoqsBdOCMck5W2qdrd")
        PFAnalytics()
		
		let theData = JiraData()
		theData.date_task_finished = NSDate()
		theData.notes = "task 3452, fixed by deleting the project"
		theData.saveInBackgroundWithBlock { (success, error) -> Void in
			println("saved")
			println(success)
			println(error)
		}
		
		var query = PFQuery(className: "JiraData")
//		query.findObjectsInBackgroundWithBlock {
//			(objects: Array<AnyObject>!, error: NSError!) -> Void in
//			println(objects!)
//			for obj in objects {
//				let o = obj as JiraData
//				println(o.date_task_finished)
//				println(o.notes)
//			}
//		}
		query.getObjectInBackgroundWithId("RNfW4Fgg5y") {
			(data: PFObject!, error: NSError!) -> Void in
			println(data["date_task_finished"])
			println(data["notes"])
			if error != nil {
				println(data)
			} else {
				println(error)
			}
		}
		
        // Insert code here to initialize your application// NSSquareStatusItemLength
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        self.statusItem?.menu = self.statusMenu
        self.statusItem?.title = "Jira"
        self.statusItem?.highlightMode = true
		self.statusItem?.action = Selector("handleStatusItemToggle:");
		self.window?.orderOut(self)
    }
	
	func handleStatusItemToggle(sender: NSStatusItem) {
		println(sender);
	}
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

