//
//  TaskSuggestionViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa
import RCLog

class TaskSuggestionViewController: NSViewController {
    
    @IBOutlet private weak var segmentedControl: NSSegmentedControl?
    @IBOutlet private weak var projectSelector: NSPopUpButton!
    @IBOutlet private weak var titleTextField: NSTextField!
    @IBOutlet private weak var notesTextField: NSTextField!
    
    var presenter: TaskSuggestionPresenterInput?
    var startSleepDate: Date?
    var endSleepDate: Date?

    deinit {
        RCLog("deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter!.setup(startSleepDate: startSleepDate, endSleepDate: endSleepDate)
    }
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        presenter!.selectSegment(atIndex: sender.selectedSegment)
    }
    
    @IBAction func handleIgnoreButton (_ sender: NSButton) {
        AppDelegate.sharedApp().removeActivePopup()
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        presenter!.save(selectedSegment: segmentedControl != nil ? segmentedControl!.selectedSegment : -1,
                        selectedProjectIndex: projectSelector.indexOfSelectedItem,
                        notes: notesTextField.stringValue,
                        startSleepDate: startSleepDate,
                        endSleepDate: endSleepDate)
        AppDelegate.sharedApp().removeActivePopup()
    }
}

extension TaskSuggestionViewController: TaskSuggestionPresenterOutput {
    
    func selectSegment (atIndex index: Int) {
        segmentedControl!.selectedSegment = index
    }
    
    func setTime (_ notes: String) {
        titleTextField.stringValue = notes
    }
    
    func setNotes (_ notes: String) {
        notesTextField.stringValue = notes
    }
    
    func setProjects (_ projects: [String]) {
        projectSelector.removeAllItems()
        projectSelector.addItems(withTitles: projects)
        projectSelector.selectItem(at: 0)
    }
    
    func hideTaskTypes() {
        segmentedControl!.removeFromSuperview()
        segmentedControl = nil
        projectSelector!.removeFromSuperview()
        projectSelector = nil
//        notesTextField.removeAutoresizing()
//        _ = notesTextField.constraintToBottom(self.view, distance: CGFloat(0))
    }
}
