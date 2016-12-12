//
//  TaskSuggestionViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

class TaskSuggestionViewController: NSViewController {
    
    @IBOutlet fileprivate weak var segmentedControl: NSSegmentedControl!
    @IBOutlet fileprivate weak var titleTextField: NSTextField!
    @IBOutlet fileprivate weak var notesTextField: NSTextField!
    
    var presenter: TaskSuggestionPresenterInput?
    var startSleepDate: Date?
    var endSleepDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter!.setup(startSleepDate: startSleepDate, endSleepDate: endSleepDate)
    }
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        presenter!.selectSegment(atIndex: segmentedControl.selectedSegment)
    }
    
    @IBAction func handleIgnoreButton (_ sender: NSButton) {
        AppDelegate.sharedApp().removeActivePopup()
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        presenter!.save(selectedSegment: segmentedControl.selectedSegment,
                        notes: notesTextField.stringValue,
                        startSleepDate: startSleepDate,
                        endSleepDate: endSleepDate)
        AppDelegate.sharedApp().removeActivePopup()
    }
}

extension TaskSuggestionViewController: TaskSuggestionPresenterOutput {
    
    func setTaskType (_ taskType: TaskSubtype) {
        segmentedControl.selectedSegment = taskType.rawValue
    }
    
    func setTime (_ notes: String) {
        titleTextField.stringValue = notes
    }
    
    func setNotes (_ notes: String) {
        notesTextField.stringValue = notes
    }
    
    func hideTaskTypes() {
        segmentedControl.removeFromSuperview()
//        notesTextField.removeAutoresizing()
//        _ = notesTextField.constraintToBottom(self.view, distance: CGFloat(0))
    }
}
