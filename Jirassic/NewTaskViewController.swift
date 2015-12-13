//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
	
	@IBOutlet private var issueTypeTextField: NSTextField?
	@IBOutlet private var issueNrTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var dateTextField: NSTextField?
	
	var onOptionChosen: ((i: TaskSubtype) -> Void)?
	var onCancelChosen: (Void -> Void)?
	
	// Sets the end date of the task to the UI picker. It can be edited and requested back
	var date: NSDate {
		get {
			let hm = NSDate.parseHHmm(self.dateTextField!.stringValue)
			return NSDate().dateByUpdatingHour(hm.hour, minute: hm.min)
		}
		set {
			self.dateTextField?.stringValue = newValue.HHmm()
		}
	}
	var notes: String {
		get {
			return notesTextField!.stringValue
		}
		set {
			self.notesTextField?.stringValue = newValue
		}
	}
	var issue: String {
		get {
			return issueNrTextField!.stringValue
		}
		set {
			self.issueNrTextField?.stringValue = newValue
		}
	}
	
	class func instanceFromStoryboard() -> NewTaskViewController {
		
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		return storyboard.instantiateControllerWithIdentifier("NewTaskViewController") as! NewTaskViewController
	}
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	@IBAction func handleScrumBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .ScrumBegin)
	}
	
	@IBAction func handleScrumEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .ScrumEnd)
	}
	
	@IBAction func handleLunchBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .LunchBegin)
	}
	
	@IBAction func handleLunchEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .LunchEnd)
	}
	
	@IBAction func handleTaskBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .IssueBegin)
	}
	
	@IBAction func handleTaskEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .IssueEnd)
	}
	
	@IBAction func handleMeetingBeginButton(sender: NSButton) {
		self.onOptionChosen?(i: .IssueBegin)
	}
	
	@IBAction func handleMeetingEndButton(sender: NSButton) {
		self.onOptionChosen?(i: .IssueEnd)
	}
	
	@IBAction func handleCancelButton(sender: NSButton) {
		self.onCancelChosen?()
	}
	
}
