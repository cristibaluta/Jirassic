//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	
    // Jit
    @IBOutlet fileprivate var jitImageView: NSImageView!
    @IBOutlet fileprivate var jitTextField: NSTextField!
    @IBOutlet fileprivate var butInstallJit: NSButton!
    // Jirassic
    @IBOutlet fileprivate var jirassicImageView: NSImageView!
    @IBOutlet fileprivate var jirassicTextField: NSTextField!
    @IBOutlet fileprivate var butInstallJirassic: NSButton!
    // Code reviews support
    @IBOutlet fileprivate var coderevImageView: NSImageView!
    @IBOutlet fileprivate var coderevTextField: NSTextField!
    @IBOutlet fileprivate var butInstallCoderev: NSButton!
    // Settings
    @IBOutlet fileprivate var butEnableStartOfDay: NSButton!
    @IBOutlet fileprivate var butEnableLunch: NSButton!
    @IBOutlet fileprivate var butEnableScrum: NSButton!
    @IBOutlet fileprivate var butEnableMeetings: NSButton!
    @IBOutlet fileprivate var butEnableAutoTrack: NSButton!
    @IBOutlet fileprivate var butEnableLaunchAtStartup: NSButton!
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
        createLayer()
        
        presenter!.loadJitInfo()
        presenter!.showSettings()
        butEnableStartOfDay.toolTip = "Working hours. Automatic logs can happen only in this interval. If you started the day at a different hour the end of the day shifts accordingly."
        butEnableLunch.toolTip = "Lunch and waste logs are ignored when calculating the amount of worked hours."
        butEnableMeetings.toolTip = "Valid intervals are considered meetings by default."
//        shellSupportTextField.stringValue = "1) Install the apple script to '~/Library/Application Scripts'\n\n2) Apple script installs jit and jirassic command line tools to '/usr/local/bin'\n   - jit: Replacement for git\n   - jirassic: Use Jirassic from the cmd"
    }
    
    deinit {
        RCLog("deinit")
    }
	
	
	// MARK: Actions
    
    @IBAction func handleInstallButton (_ sender: NSButton) {
        NSWorkspace.shared().open( URL(string: "http://www.jirassic.com/#extensions")!)
//        if sender.title == "Install" {
//            presenter!.installTools()
//        } else {
//            presenter!.uninstallTools()
//        }
    }
    
    @IBAction func handleSaveJiraSettingsButton (_ sender: NSButton) {
        
//        let settings = JiraSettings(url: jiraUrlTextField.stringValue,
//                                    user: jiraUserTextField.stringValue,
//                                    password: jiraPasswordTextField.stringValue != "" ? jiraPasswordTextField.stringValue : nil,
//                                    separator: nil)
//        presenter!.saveJiraSettings(settings)
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
    
    @IBAction func handleLaunchAtStartupButton (_ sender: NSButton) {
        presenter!.enabledLaunchAtStartup(sender.state == NSOnState)
    }
}

extension SettingsViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func setJitCmdIsInstalled (_ installed: Bool) {
        
        jitImageView.image = NSImage(named: installed ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
        jitTextField.stringValue = installed ? "Commit to git with Jit. Run 'jit' in Terminal for more info" : "Not installed yet"
        butInstallJit.isHidden = installed
    }
    
    func setJirassicCmdIsInstalled (_ installed: Bool) {
        
        jirassicImageView.image = NSImage(named: installed ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
        jirassicTextField.stringValue = installed ? "Run 'jirassic' in Terminal for more info" : "Not installed yet"
        butInstallJirassic.isHidden = installed
    }
    
    func setCodeReviewIsInstalled (_ installed: Bool) {
        
        coderevImageView.image = NSImage(named: installed ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
        coderevTextField.stringValue = installed ? "Time spent in stash is tracked as code review" : "Not installed yet"
        butInstallCoderev.isHidden = installed
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
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        butEnableLaunchAtStartup.state = enabled ? NSOnState : NSOffState
    }
    
}
