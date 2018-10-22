//
//  EndDayViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class EndDayViewController: NSViewController {
    
    @IBOutlet private var dateTextField: NSTextField!
    @IBOutlet private var durationTextField: NSTextField!
    @IBOutlet private var worklogTextView: NSTextView!
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    @IBOutlet private var butJira: NSButton!
    @IBOutlet private var butJiraSetup: NSButton!
    @IBOutlet private var jiraErrorTextField: NSTextField!
    @IBOutlet private var butRound: NSButton!
    @IBOutlet private var butSave: NSButton!
    
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
        jiraErrorTextField.textColor = isError ? NSColor.red : NSColor(red: 76/255, green: 172/255, blue: 44/255, alpha: 1.0)
    }
}
