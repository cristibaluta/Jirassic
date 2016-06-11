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
	
	var onOptionChosen: ((taskData: TaskCreationData) -> Void)?
	var onCancelChosen: (Void -> Void)?
    private var _dateEnd = ""
    private var issueTypes = [String]()
	
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
	
	@IBAction func handleScrumEndButton (sender: NSButton) {
		setTaskDataWithTaskType(.ScrumEnd)
	}
	
	@IBAction func handleLunchEndButton (sender: NSButton) {
		setTaskDataWithTaskType(.LunchEnd)
	}
	
	@IBAction func handleTaskEndButton (sender: NSButton) {
		setTaskDataWithTaskType(.IssueEnd)
	}
	
	@IBAction func handleMeetingEndButton (sender: NSButton) {
		setTaskDataWithTaskType(.IssueEnd)
	}
	
	@IBAction func handleCancelButton (sender: NSButton) {
		self.onCancelChosen?()
	}
	
    func setTaskDataWithTaskType (taskSubtype: TaskSubtype) {
        
        let taskData = TaskCreationData(
            dateEnd: date,
            issueType: issueType,
            issueId: issueId,
            notes: notes
        )
        self.onOptionChosen?(taskData: taskData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        issueTypeComboBox?.usesDataSource = true
        issueTypeComboBox?.setDelegate(self)
        issueTypeComboBox?.dataSource = self
        issueTypeComboBox?.completes = true
        
        let issuesReader = IssuesInteractor(data: localRepository)
        issuesReader.allIssues { (issues) in
            self.issueTypes = issues
            self.issueTypeComboBox?.reloadData()
        }
    }
}

extension NewTaskViewController: NSComboBoxDelegate, NSComboBoxDataSource {
    
    func numberOfItemsInComboBox (aComboBox: NSComboBox) -> Int {
        return issueTypes.count
    }
    
    func comboBox (aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        return issueTypes[index]
    }
    
    func comboBox (aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return 0//issueTypes.indexOfObject(string)
    }
    
    func comboBox (aComboBox: NSComboBox, completedString string: String) -> String? {
        print("completedString \(string)")
        return nil
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing (obj: NSNotification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == startDateTextField || textField == endDateTextField || textField == durationTextField else {
                return
            }
            _dateEnd = textField.stringValue
        }
    }
    
    override func controlTextDidChange (obj: NSNotification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == startDateTextField || textField == endDateTextField || textField == durationTextField else {
                return
            }
            let predictor = PredictiveTimeTyping()
            let comps = textField.stringValue.componentsSeparatedByString(_dateEnd)
            let newDigit = (comps.count == 1 && _dateEnd != "") ? "" : comps.last
            _dateEnd = predictor.timeByAdding(newDigit!, to: _dateEnd)
            textField.stringValue = _dateEnd
        }
    }
}
