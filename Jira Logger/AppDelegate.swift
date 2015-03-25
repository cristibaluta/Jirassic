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

	@IBOutlet weak var window: NSWindow!
    @IBOutlet var statusMenu :NSMenu?;
    var statusItem :NSStatusItem?;
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/OSX
        
        println(1)
        
        Parse.enableLocalDatastore()
        println(1)
        // Initialize Parse.
        Parse.setApplicationId("DFWPmEOCnRCody7tfeXjzNZAl6nKCaTZELWSEeyZ", clientKey:"WdjHVrrPJexhd4nnFZyOx9GoqsBdOCMck5W2qdrd")
        // [Optional] Track statistics around application opens.
        //        PFAnalytics()
        println(1)
        
        let testObject = PFObject(className: "TestObject")
        println(testObject)
        testObject["foo"] = "bar"
        println(testObject)
        testObject.saveInBackgroundWithBlock { (success, error) -> Void in
            println("saved")
        }
        
        // Insert code here to initialize your application// NSSquareStatusItemLength
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        self.statusItem?.menu = self.statusMenu
        self.statusItem?.title = "Jira Logger"
        self.statusItem?.highlightMode = true
		self.statusItem?.action = Selector("handleStatusItemToggle:");
		self.window?.orderOut(self)
    }
	
	func handleStatusItemToggle(sender:NSStatusItem) {
		println(sender);
	}
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

