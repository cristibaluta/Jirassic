//
//  NoTasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NoTasksViewController: NSViewController {

	@IBOutlet private var _noTasksLabel: NSTextField?
	@IBOutlet private var _butStart: NSButton?
	
	var handleStartButton: (() -> ())?
	
	class func instanceFromStoryboard() -> NoTasksViewController {
		
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateControllerWithIdentifier("NoTasksViewController") as! NoTasksViewController
		return vc
	}
	
	func showStartState() {
		_noTasksLabel?.stringValue = NoTasks().showStartState()
		_butStart?.hidden = false
	}
	
	func showFirstTaskState() {
		_noTasksLabel?.stringValue = NoTasks().showFirstTaskState()
		_butStart?.hidden = true
	}
	
	
	// MARK: Actions
	
	@IBAction func handleStartButton(sender: NSButton) {
		self.handleStartButton?()
	}
}
