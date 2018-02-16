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
    @IBOutlet fileprivate var butJira: NSButton!
    @IBOutlet fileprivate var butJiraSetup: NSButton!
    @IBOutlet fileprivate var jiraErrorTextField: NSTextField!
    @IBOutlet fileprivate var butHookup: NSButton!
    @IBOutlet fileprivate var hookupErrorTextField: NSTextField!
    @IBOutlet fileprivate var butRound: NSButton!
    @IBOutlet fileprivate var butSave: NSButton!

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var presenter: EndDayPresenterInput?
    var date: Date?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    weak var appWireframe: AppWireframe?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter!.setup(date: date!)
        dateTextField.stringValue = date!.EEEEMMMdd()
        jiraErrorTextField.stringValue = ""
        hookupErrorTextField.stringValue = ""
        
        worklogTextView.drawsBackground = false
        worklogTextView.backgroundColor = NSColor.clear
    }

    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancel?()
    }

    @IBAction func handleSaveButton (_ sender: NSButton) {
        presenter?.save(jiraTempo: true, roundTime: true, worklog: worklogTextView.string)
    }
    
    @IBAction func handleJiraButton (_ sender: NSButton) {
        localPreferences.set(sender.state == .on, forKey: .enableJira)
    }
    
    @IBAction func handleJiraSetupButton (_ sender: NSButton) {
        localPreferences.set(SettingsTab.output.rawValue, forKey: .settingsActiveTab)
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleHookupButton (_ sender: NSButton) {
        localPreferences.set(sender.state == .on, forKey: .enableHookup)
    }
    
    @IBAction func handleRoundButton (_ sender: NSButton) {
        localPreferences.set(sender.state == .on, forKey: .enableRoundingDay)
    }
}

extension EndDayViewController: EndDayPresenterOutput {

    func showJira (enabled: Bool, available: Bool) {
        butJira.isEnabled = available
        butJira.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
        butJiraSetup.isHidden = available
    }
    
    func showHookup (enabled: Bool, available: Bool) {
        butHookup.isEnabled = available
        butHookup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func showRounding (enabled: Bool, title: String) {
        butRound.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
        butRound.title = title
    }
    
    func showWorklog (_ worklog: String) {
        worklogTextView.string = worklog
    }
    
    func showProgressIndicator (_ show: Bool) {
        if show {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
    }
}
