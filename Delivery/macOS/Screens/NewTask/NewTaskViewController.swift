//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    
    @IBOutlet fileprivate var taskTypeSegmentedControl: NSSegmentedControl?
	@IBOutlet fileprivate var issueIdTextField: NSTextField?
	@IBOutlet fileprivate var notesTextField: NSTextField?
	@IBOutlet fileprivate var endDateTextField: NSTextField?
	@IBOutlet fileprivate var durationTextField: NSTextField?
	
	var onOptionChosen: ((_ taskData: TaskCreationData) -> Void)?
	var onCancelChosen: ((Void) -> Void)?
    fileprivate var _dateEnd = ""
    fileprivate var issueTypes = [String]()
	
	// Sets the end date of the task to the UI picker. It can be edited and requested back
	var date: Date {
		get {
			let hm = Date.parseHHmm(self.endDateTextField!.stringValue)
			return Date().dateByUpdating(hour: hm.hour, minute: hm.min)
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
	var taskNumber: String {
		get {
			return issueIdTextField!.stringValue
		}
		set {
			self.issueIdTextField?.stringValue = newValue
		}
	}
	
    func setTaskDataWithTaskType (_ taskSubtype: TaskSubtype) {
        
        let taskData = TaskCreationData(
            dateEnd: date,
            taskNumber: taskNumber,
            notes: notes
        )
        self.onOptionChosen?(taskData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTypeSegmentedControl?.selectedSegment = 0
    }
    
    override func viewDidLayout() {
        
    }
}

extension NewTaskViewController: NSComboBoxDelegate, NSComboBoxDataSource {
    
    func numberOfItems (in aComboBox: NSComboBox) -> Int {
        return issueTypes.count
    }
    
    func comboBox (_ aComboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return issueTypes[index]
    }
    
    func comboBox (_ aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return 0//issueTypes.indexOfObject(string)
    }
    
    func comboBox (_ aComboBox: NSComboBox, completedString string: String) -> String? {
        print("completedString \(string)")
        return nil
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == durationTextField else {
                return
            }
            _dateEnd = textField.stringValue
        }
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == durationTextField else {
                return
            }
            let predictor = PredictiveTimeTyping()
            let comps = textField.stringValue.components(separatedBy: _dateEnd)
            let newDigit = (comps.count == 1 && _dateEnd != "") ? "" : comps.last
            _dateEnd = predictor.timeByAdding(newDigit!, to: _dateEnd)
            textField.stringValue = _dateEnd
        }
    }
}

extension NewTaskViewController {
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        
        var taskType: TaskSubtype = .issueEnd
        
        switch taskTypeSegmentedControl!.selectedSegment {
        case 0: taskType = .issueEnd
        case 1: taskType = .scrumEnd
        case 2: taskType = .meetingEnd
        case 3: taskType = .lunchEnd
        default: break
        }
        RCLogO(taskType)
        setTaskDataWithTaskType(taskType)
    }
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancelChosen?()
    }
}
