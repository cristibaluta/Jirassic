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
    @IBOutlet fileprivate var durationTextField: NSTextField!
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
    var tasks: [Task]?
    weak var appWireframe: AppWireframe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTextField.stringValue = date!.EEEEMMMdd()
        jiraErrorTextField.stringValue = ""
        hookupErrorTextField.stringValue = ""
        
        worklogTextView.drawsBackground = false
        worklogTextView.backgroundColor = NSColor.clear
        
        presenter!.setup(date: date!, tasks: tasks!)
    }
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancel?()
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        presenter!.save(worklog: worklogTextView.string)
    }
    
    @IBAction func handleJiraButton (_ sender: NSButton) {
        presenter!.enableJira(sender.state == .on)
    }
    
    @IBAction func handleJiraSetupButton (_ sender: NSButton) {
        RCPreferences<LocalPreferences>().set(SettingsTab.output.rawValue, forKey: .settingsActiveTab)
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleHookupButton (_ sender: NSButton) {
        presenter!.enableHookup(sender.state == .on)
    }
    
    @IBAction func handleRoundButton (_ sender: NSButton) {
        presenter!.enableRounding(sender.state == .on)
    }
}

extension EndDayViewController: EndDayPresenterOutput {
    
    func showJira (enabled: Bool, available: Bool) {
        butJira.isEnabled = available
        butJira.state = enabled ? .on : .off
        butJiraSetup.isHidden = available
    }
    
    func showHookup (enabled: Bool, available: Bool) {
        butHookup.isEnabled = available
        butHookup.state = enabled ? .on : .off
    }
    
    func showRounding (enabled: Bool, title: String) {
        butRound.state = enabled ? .on : .off
        butRound.title = title
    }
    
    func showDuration (_ duration: Double) {
        durationTextField.stringValue = String(describing: duration)
    }
    
    func showWorklog (_ worklog: String) {
        worklogTextView.string = worklog
    }
    
    func showProgressIndicator (_ show: Bool) {
        show
            ? progressIndicator.startAnimation(nil)
            : progressIndicator.stopAnimation(nil)
    }
    
    func showJiraMessage (_ message: String, isError: Bool) {
        jiraErrorTextField.stringValue = message
        jiraErrorTextField.textColor = isError ? NSColor.red : NSColor.green
    }
    
    func showHookupMessage (_ message: String, isError: Bool) {
        hookupErrorTextField.stringValue = message
        hookupErrorTextField.textColor = isError ? NSColor.red : NSColor.green
    }
}
