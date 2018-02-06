//
//  EndDayViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class EndDayViewController: NSViewController {

    @IBOutlet fileprivate var dateTextField: NSTextField!
    @IBOutlet fileprivate var worklogTextView: NSTextView!
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator!
    @IBOutlet fileprivate var butRound: NSButton!
    @IBOutlet fileprivate var butJira: NSButton!
    @IBOutlet fileprivate var butSetupJira: NSButton!
    @IBOutlet fileprivate var butSave: NSButton!

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var presenter: EndDayPresenterInput?
    var date: Date?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter!.setup(date: date!)
        dateTextField.stringValue = date!.EEEEMMMMdd()
    }

    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancel?()
    }

    @IBAction func handleSaveButton (_ sender: NSButton) {
        presenter?.save(jiraTempo: true, roundTime: true, worklog: worklogTextView.string)
    }
}

extension EndDayViewController: EndDayPresenterOutput {

    func showJira (enabled: Bool, available: Bool) {
        
    }
    
    func showHookup (enabled: Bool, available: Bool) {
        
    }
    
    func showWorklog (_ worklog: String) {
        worklogTextView.string = worklog
    }

    func showRounding (enabled: Bool, title: String) {
        butRound.state = localPreferences.bool(.roundDay)  ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func showProgressIndicator (_ show: Bool) {
        if show {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
    }
}
