//
//  JRApplication.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

//class JRApplication: NSApplication {
extension NSApplication {
	
	func addGitTask (taskId: String, commitDescription: String) {
		RCLog("AppleScript arrived")
		RCLog(taskId)
		RCLog(commitDescription)
	}
	
	func handleQuitScriptCommand2() {
		RCLog("AppleScript arrived, quit the app")
	}
}
