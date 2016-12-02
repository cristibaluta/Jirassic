//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import CloudKit

class SettingsViewController: NSViewController {
	
    // Jit
    @IBOutlet fileprivate var jitImageView: NSImageView?
    @IBOutlet fileprivate var jitTextField: NSTextField?
    @IBOutlet fileprivate var butInstallJit: NSButton?
    // Jira
    @IBOutlet fileprivate var jiraUrlTextField: NSTextField?
    @IBOutlet fileprivate var jiraUserTextField: NSTextField?
    @IBOutlet fileprivate var jiraPasswordTextField: NSTextField?
    // Settings
    @IBOutlet fileprivate var butAutoTrackStartOfDay: NSButton!
    @IBOutlet fileprivate var butAutoTrackLunch: NSButton!
    @IBOutlet fileprivate var butAutoTrackScrum: NSButton!
    @IBOutlet fileprivate var butAutoTrackMeetings: NSButton!
    @IBOutlet fileprivate var butWakeUpSuggestions: NSButton!
    @IBOutlet fileprivate var startOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var lunchTimePicker: NSDatePicker!
    @IBOutlet fileprivate var scrumMeetingTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minMeetingDurationTimePicker: NSDatePicker!
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
	
    override func viewDidAppear() {
        super.viewDidAppear()
        
        presenter!.loadJitInfo()
        presenter!.showSettings()
    }
    
    deinit {
        RCLog("deinit")
    }
	
	
	// MARK: Actions
    
    @IBAction func handleInstallJitButton (_ sender: NSButton) {
        if sender.title == "Install" {
            presenter!.installJit()
        } else {
            presenter!.uninstallJit()
        }
    }
    
	@IBAction func handleSaveButton (_ sender: NSButton) {
		
        let settings = Settings(autoTrackStartOfDay: butAutoTrackStartOfDay.state == NSOnState,
                                autoTrackLunch: butAutoTrackLunch.state == NSOnState,
                                autoTrackScrum: butAutoTrackScrum.state == NSOnState,
                                autoTrackMeetings: butAutoTrackMeetings.state == NSOnState,
                                showWakeUpSuggestions: butWakeUpSuggestions.state == NSOnState,
                                startOfDayTime: startOfDayTimePicker.dateValue,
                                lunchTime: lunchTimePicker.dateValue,
                                scrumMeetingTime: scrumMeetingTimePicker.dateValue,
                                minMeetingDuration: minMeetingDurationTimePicker.dateValue
        )
        presenter!.saveAppSettings(settings)
        
        appWireframe!.flipToTasksController()
	}
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func setJitIsInstalled (_ installed: Bool) {
        
        jitImageView?.image = NSImage(named: installed ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
        jitTextField?.stringValue = installed ? "Shell support is installed" : "Shell support not installed yet"
        butInstallJit!.title = installed ? "Uninstall" : "Install"
    }
    
    func setJiraSettings (_ settings: JiraSettings) {
        
        jiraUrlTextField!.stringValue = settings.url ?? ""
        jiraUserTextField!.stringValue = settings.user ?? ""
//        jiraPasswordTextField!.stringValue = nil
    }
    
    func showAppSettings (_ settings: Settings) {
        
        butAutoTrackStartOfDay.state = settings.autoTrackStartOfDay ? NSOnState : NSOffState
        butAutoTrackLunch.state = settings.autoTrackLunch ? NSOnState : NSOffState
        butAutoTrackScrum.state = settings.autoTrackScrum ? NSOnState : NSOffState
        butAutoTrackMeetings.state = settings.autoTrackMeetings ? NSOnState : NSOffState
        butWakeUpSuggestions.state = settings.showWakeUpSuggestions ? NSOnState : NSOffState
        
        lunchTimePicker.dateValue = settings.lunchTime
        scrumMeetingTimePicker.dateValue = settings.scrumMeetingTime
        startOfDayTimePicker.dateValue = settings.startOfDayTime
        minMeetingDurationTimePicker.dateValue = settings.minMeetingDuration
    }
}
