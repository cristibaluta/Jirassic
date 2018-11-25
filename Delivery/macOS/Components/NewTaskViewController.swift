//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    
    @IBOutlet private weak var taskTypeSelector: NSPopUpButton!
	@IBOutlet private weak var issueIdTextField: NSTextField!
	@IBOutlet private weak var notesTextField: NSTextField!
	@IBOutlet private weak var endDateTextField: NSTextField!
    @IBOutlet private weak var startDateTextField: NSTextField!
    @IBOutlet private weak var startDateButton: NSButton!
	
	var onSave: ((_ taskData: TaskCreationData) -> Void)?
	var onCancel: (() -> Void)?
    private var activeEditingTextFieldContent = ""
    private var issueTypes = [String]()
    private let predictor = PredictiveTimeTyping()
    private let pref = RCPreferences<LocalPreferences>()
	
    var dateStart: Date? {
        get {
            if pref.bool(.useDuration) {
                return self.duration > 0 ? self.dateEnd.addingTimeInterval(-self.duration) : nil
            } else {
                if self.startDateTextField!.stringValue == "" {
                    return nil
                }
                let hm = Date.parseHHmm(self.startDateTextField!.stringValue)
                return self.initialDate.dateByUpdating(hour: hm.hour, minute: hm.min)
            }
        }
        set {
            if let startDate = newValue {
                self.startDateTextField.stringValue = startDate.HHmm()
            }
        }
    }
    var initialDate = Date()
	var dateEnd: Date {
		get {
            let hm = Date.parseHHmm(self.endDateTextField!.stringValue)
            return self.initialDate.dateByUpdating(hour: hm.hour, minute: hm.min)
		}
		set {
            self.initialDate = newValue
            self.endDateTextField.stringValue = newValue.HHmm()
            self.estimateTaskType()
		}
	}
    var duration: TimeInterval {
        get {
            if self.startDateTextField.stringValue == "" {
                return 0.0
            }
            let hm = Date.parseHHmm(self.startDateTextField.stringValue)
            return Double(hm.min).minToSec + Double(hm.hour).hoursToSec
        }
    }
	var notes: String {
		get {
			return notesTextField.stringValue
		}
		set {
			self.notesTextField.stringValue = newValue
		}
	}
	var taskNumber: String {
		get {
			return issueIdTextField.stringValue
		}
		set {
			self.issueIdTextField.stringValue = newValue
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTypeSelector.removeAllItems()
        taskTypeSelector.addItems(withTitles: ["Task", "Scrum", "Meeting", "Food", "Social & Media", "Learning", "Code review"])
        taskTypeSelector.selectItem(at: 0)
        setupStartDateButtonTitle()
        startDateTextField.toolTip = "Predictive Time Typing (use digits and backspace):\n • First digit if between 2 and 9 means AM hours.\n • Leaving minutes empty, defaults to 00.\n • Last digit replaces itself, no need to delete."
        endDateTextField.toolTip = startDateTextField.toolTip
    }
    
    private func selectedTaskType() -> TaskType {
        
        switch taskTypeSelector.indexOfSelectedItem {
            case 0: return .issue
            case 1: return .scrum
            case 2: return .meeting
            case 3: return .lunch
            case 4: return .waste
            case 5: return .learning
            case 6: return .coderev
            default: return .issue
        }
    }
    
    private func estimateTaskType() {
        
        let typeEstimator = TaskTypeEstimator()
        let settings = SettingsInteractor().getAppSettings()
        let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(initialDate, withSettings: settings)
        if estimatedType == .scrum {
            taskTypeSelector.selectItem(at: 1)
            handleTaskTypeSelector(taskTypeSelector)
            
            let settingsScrumTime = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.settingsTracking.scrumTime)
            self.dateStart = self.initialDate.dateByUpdating(hour: settingsScrumTime.hour!, minute: settingsScrumTime.minute!)
        }
    }
    
    private func setupStartDateButtonTitle() {
        startDateButton.title = pref.bool(.useDuration) ? "Duration" : "Date start"
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == startDateTextField else {
                return
            }
            activeEditingTextFieldContent = textField.stringValue
        }
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == startDateTextField else {
                return
            }
            let comps = textField.stringValue.map { String($0) }
            let newDigit = activeEditingTextFieldContent.count > comps.count ? "" : comps.last
            activeEditingTextFieldContent = predictor.timeByAdding(newDigit!, to: activeEditingTextFieldContent)
            textField.stringValue = activeEditingTextFieldContent
        }
    }
}

extension NewTaskViewController {
    
    @IBAction func handleTaskTypeSelector (_ sender: NSPopUpButton) {
        issueIdTextField.isEnabled = selectedTaskType() == .issue
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        
        let taskData = TaskCreationData(
            dateStart: self.dateStart,
            dateEnd: self.dateEnd,
            taskNumber: self.taskNumber != "" ? self.taskNumber : nil,
            notes: self.notes != "" ? self.notes : nil,
            taskType: selectedTaskType()
        )
        self.onSave?(taskData)
    }
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancel?()
    }
    
    @IBAction func handleDurationButton (_ sender: NSButton) {
        
        pref.set(!pref.bool(.useDuration), forKey: .useDuration)
        setupStartDateButtonTitle()
    }
}

extension NewTaskViewController {
    
    override func mouseDown(with event: NSEvent) {
//        RCLog(event)
    }
}
