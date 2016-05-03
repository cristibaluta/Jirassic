//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
	
	@IBOutlet private var issueTypeComboBox: NSComboBox?
	@IBOutlet private var issueIdTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var startDateTextField: NSTextField?
	@IBOutlet private var endDateTextField: NSTextField?
	@IBOutlet private var durationTextField: NSTextField?
	
	var onOptionChosen: ((i: TaskSubtype) -> Void)?
	var onCancelChosen: (Void -> Void)?
	
	// Sets the end date of the task to the UI picker. It can be edited and requested back
	var date: NSDate {
		get {
			let hm = NSDate.parseHHmm(self.endDateTextField!.stringValue)
			return NSDate().dateByUpdatingHour(hm.hour, minute: hm.min)
		}
		set {
			self.endDateTextField?.stringValue = newValue.HHmm()
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
	var issueType: String {
		get {
			return issueTypeComboBox!.stringValue
		}
		set {
			self.issueTypeComboBox?.stringValue = newValue
		}
	}
	var issueId: String {
		get {
			return issueIdTextField!.stringValue
		}
		set {
			self.issueIdTextField?.stringValue = newValue
		}
	}
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	@IBAction func handleScrumBeginButton (sender: NSButton) {
		self.onOptionChosen?(i: .ScrumBegin)
	}
	
	@IBAction func handleScrumEndButton (sender: NSButton) {
		self.onOptionChosen?(i: .ScrumEnd)
	}
	
	@IBAction func handleLunchBeginButton (sender: NSButton) {
		self.onOptionChosen?(i: .LunchBegin)
	}
	
	@IBAction func handleLunchEndButton (sender: NSButton) {
		self.onOptionChosen?(i: .LunchEnd)
	}
	
	@IBAction func handleTaskBeginButton (sender: NSButton) {
		self.onOptionChosen?(i: .IssueBegin)
	}
	
	@IBAction func handleTaskEndButton (sender: NSButton) {
		self.onOptionChosen?(i: .IssueEnd)
	}
	
	@IBAction func handleMeetingBeginButton (sender: NSButton) {
		self.onOptionChosen?(i: .IssueBegin)
	}
	
	@IBAction func handleMeetingEndButton (sender: NSButton) {
		self.onOptionChosen?(i: .IssueEnd)
	}
	
	@IBAction func handleCancelButton (sender: NSButton) {
		self.onCancelChosen?()
	}
	
}
