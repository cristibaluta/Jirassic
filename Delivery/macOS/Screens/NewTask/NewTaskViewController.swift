//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    
    @IBOutlet fileprivate weak var taskTypeSegmentedControl: NSSegmentedControl!
	@IBOutlet fileprivate weak var issueIdTextField: NSTextField!
	@IBOutlet fileprivate weak var notesTextField: NSTextField!
	@IBOutlet fileprivate weak var endDateTextField: NSTextField!
	@IBOutlet fileprivate weak var durationTextField: NSTextField!
	
	var onOptionChosen: ((_ taskData: TaskCreationData) -> Void)?
	var onCancelChosen: ((Void) -> Void)?
    fileprivate var activeEditingTextFieldContent = ""
    fileprivate var issueTypes = [String]()
    fileprivate let predictor = PredictiveTimeTyping()
	
	// Sets the end date of the task to the UI picker. It can be edited and requested back
    var initialDate = Date()
	var dateEnd: Date {
		get {
			let hm = Date.parseHHmm(self.endDateTextField!.stringValue)
			return self.initialDate.dateByUpdating(hour: hm.hour, minute: hm.min)
		}
		set {
            self.initialDate = newValue
			self.endDateTextField?.stringValue = newValue.HHmm()
		}
	}
    var duration: TimeInterval {
        get {
            if self.durationTextField!.stringValue == "" {
                return 0.0
            }
            let hm = Date.parseHHmm(self.durationTextField!.stringValue)
            return Double(hm.min).minToSec + Double(hm.hour).hoursToSec
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
            dateStart: self.duration > 0 ? self.dateEnd.addingTimeInterval(-self.duration) : nil,
            dateEnd: self.dateEnd,
            taskNumber: self.taskNumber,
            notes: self.notes
        )
        self.onOptionChosen?(taskData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTypeSegmentedControl?.selectedSegment = 0
    }
    
    override func viewDidLayout() {
        
    }
    
    fileprivate func taskSubtype() -> TaskSubtype {
        
        switch taskTypeSegmentedControl!.selectedSegment {
            case 0: return .issueEnd
            case 1: return .scrumEnd
            case 2: return .meetingEnd
            case 3: return .lunchEnd
            case 4: return .napEnd
            case 5: return .learningEnd
            default: return .issueEnd
        }
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == durationTextField else {
                return
            }
            activeEditingTextFieldContent = textField.stringValue
        }
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == durationTextField else {
                return
            }
            let comps = textField.stringValue.characters.map { String($0) }
            let newDigit = activeEditingTextFieldContent.characters.count > comps.count ? "" : comps.last
            activeEditingTextFieldContent = predictor.timeByAdding(newDigit!, to: activeEditingTextFieldContent)
            textField.stringValue = activeEditingTextFieldContent
        }
    }
}

extension NewTaskViewController {
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        
        let subtype = taskSubtype()
        issueIdTextField.stringValue = subtype.defaultTaskNumber ?? ""
        notesTextField.stringValue = subtype.defaultNotes
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        
        let subtype = taskSubtype()
        RCLogO(subtype)
        setTaskDataWithTaskType(subtype)
    }
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancelChosen?()
    }
}
