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
	
	func showStartState() {
		_noTasksLabel?.stringValue = "Good morning! Ready for your first task?"
		_butStart?.hidden = false
	}
	
	func showFirstTaskState() {
		_noTasksLabel?.stringValue = "When you finish tasks press +\nTime will be calculated for you automatically"
		_butStart?.hidden = true
	}
	
	
	// MARK: Actions
	
	@IBAction func handleStartButton(sender: NSButton) {
		self.handleStartButton?()
	}
}
