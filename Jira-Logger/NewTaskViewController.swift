//
//  NewTaskViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
	
	var onOptionChosen: ((i: TaskSubtype) -> Void)?
	
	class func instanceFromStoryboard() -> NewTaskViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("NewTaskViewController") as! NewTaskViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	@IBAction func handleScrumBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .TaskScrumBegin)
	}
	
	@IBAction func handleScrumEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .TaskScrumEnd)
	}
	
	@IBAction func handleLunchBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .TaskLunchBegin)
	}
	
	@IBAction func handleLunchEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .TaskLunchEnd)
	}
	
	@IBAction func handleTaskBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .TaskIssueBegin)
	}
	
	@IBAction func handleTaskEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .TaskIssueEnd)
	}
	
}
