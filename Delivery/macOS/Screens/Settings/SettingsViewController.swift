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
    @IBOutlet fileprivate var butEnableStartOfDay: NSButton!
    @IBOutlet fileprivate var butEnableLunch: NSButton!
    @IBOutlet fileprivate var butEnableScrum: NSButton!
    @IBOutlet fileprivate var butEnableMeetings: NSButton!
    @IBOutlet fileprivate var butEnableAutoTrack: NSButton!
    @IBOutlet fileprivate var trackingModeSegmentedControl: NSSegmentedControl!
    @IBOutlet fileprivate var startOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var endOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var lunchTimePicker: NSDatePicker!
    @IBOutlet fileprivate var scrumTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minSleepDurationTimePicker: NSDatePicker!
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
	
    override func viewDidAppear() {
        super.viewDidAppear()
        
        presenter!.loadJitInfo()
        presenter!.showSettings()
        butEnableStartOfDay.toolTip = "The official hours you're supposed to work. Automatic logs can happen only in this interval. If you started the day at a different hour the end of the day shifts accordingly."
        butEnableLunch.toolTip = "Lunch and nap logs are ignored when calculating the amount of worked hours."
        butEnableMeetings.toolTip = "Valid intervals are considered meetings by default."
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
		
        let settings = Settings(startOfDayEnabled: butEnableStartOfDay.state == NSOnState,
                                lunchEnabled: butEnableLunch.state == NSOnState,
                                scrumEnabled: butEnableScrum.state == NSOnState,
                                meetingEnabled: butEnableMeetings.state == NSOnState,
                                autoTrackEnabled: butEnableAutoTrack.state == NSOnState,
                                trackingMode: TaskTrackingMode(rawValue: trackingModeSegmentedControl.selectedSegment)!,
                                startOfDayTime: startOfDayTimePicker.dateValue,
                                endOfDayTime: endOfDayTimePicker.dateValue,
                                lunchTime: lunchTimePicker.dateValue,
                                scrumTime: scrumTimePicker.dateValue,
                                minSleepDuration: minSleepDurationTimePicker.dateValue
        )
        presenter!.saveAppSettings(settings)
        
        appWireframe!.flipToTasksController()
	}
    
    @IBAction func handleAutoTrackButton (_ sender: NSButton) {
        trackingModeSegmentedControl.isEnabled = sender.state == NSOnState
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
        
        butEnableStartOfDay.state = settings.startOfDayEnabled ? NSOnState : NSOffState
        butEnableLunch.state = settings.lunchEnabled ? NSOnState : NSOffState
        butEnableScrum.state = settings.scrumEnabled ? NSOnState : NSOffState
        butEnableMeetings.state = settings.meetingEnabled ? NSOnState : NSOffState
        butEnableAutoTrack.state = settings.autoTrackEnabled ? NSOnState : NSOffState
        
        trackingModeSegmentedControl.selectedSegment = settings.trackingMode.rawValue
        
        startOfDayTimePicker.dateValue = settings.startOfDayTime
        endOfDayTimePicker.dateValue = settings.endOfDayTime
        lunchTimePicker.dateValue = settings.lunchTime
        scrumTimePicker.dateValue = settings.scrumTime
        minSleepDurationTimePicker.dateValue = settings.minSleepDuration
    }
}
