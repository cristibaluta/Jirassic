//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    // Extensions
    // shell
    @IBOutlet fileprivate var jirassicImageView: NSImageView!
    @IBOutlet fileprivate var jirassicTextField: NSTextField!
    @IBOutlet fileprivate var butInstallJirassic: NSButton!
    // git
    @IBOutlet fileprivate var jitImageView: NSImageView!
    @IBOutlet fileprivate var jitTextField: NSTextField!
    @IBOutlet fileprivate var butInstallJit: NSButton!
    // browser: code reviews and wasted time
    @IBOutlet fileprivate var coderevImageView: NSImageView!
    @IBOutlet fileprivate var coderevTextField: NSTextField!
    @IBOutlet fileprivate var butInstallCoderev: NSButton!
    @IBOutlet fileprivate var butTrackCodeReviews: NSButton!
    @IBOutlet fileprivate var butTrackWastedTime: NSButton!
    @IBOutlet fileprivate var codeReviewsLinkTextField: NSTextField!
    @IBOutlet fileprivate var wastedTimeLinksTextField: NSTextField!
    
    // Settings
    @IBOutlet fileprivate var butEnableLaunchAtStartup: NSButton!
    @IBOutlet fileprivate var butAutotrack: NSButton!
    @IBOutlet fileprivate var autotrackingModeSegmentedControl: NSSegmentedControl!
    @IBOutlet fileprivate var butTrackStartOfDay: NSButton!
    @IBOutlet fileprivate var butTrackLunch: NSButton!
    @IBOutlet fileprivate var butTrackScrum: NSButton!
    @IBOutlet fileprivate var butTrackMeetings: NSButton!
    @IBOutlet fileprivate var startOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var endOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var lunchTimePicker: NSDatePicker!
    @IBOutlet fileprivate var scrumTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minSleepDurationTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minCodeRevDurationTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minWasteDurationTimePicker: NSDatePicker!
    @IBOutlet fileprivate var butBackup: NSButton!
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
	
    override func viewDidAppear() {
        super.viewDidAppear()
        createLayer()
        
        presenter!.loadJitInfo()
        presenter!.showSettings()
//        butEnableStartOfDay.toolTip = "Working hours. Automatic logs can happen only in this interval. If you started the day at a different hour the end of the day shifts accordingly."
//        butEnableLunch.toolTip = "Lunch and waste logs are ignored when calculating the amount of worked hours."
//        butEnableMeetings.toolTip = "Valid intervals are considered meetings by default."
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
		
        let settings = Settings(
            
            autotrack: butAutotrack.state == NSOnState,
            autotrackingMode: TrackingMode(rawValue: autotrackingModeSegmentedControl.selectedSegment)!,
            trackLunch: butTrackLunch.state == NSOnState,
            trackScrum: butTrackScrum.state == NSOnState,
            trackMeetings: true,//butTrackMeetings.state == NSOnState,
            trackCodeReviews: butTrackCodeReviews.state == NSOnState,
            trackWastedTime: butTrackWastedTime.state == NSOnState,
            trackStartOfDay: butTrackStartOfDay.state == NSOnState,
            enableBackup: butBackup.state == NSOnState,
            startOfDayTime: startOfDayTimePicker.dateValue,
            endOfDayTime: endOfDayTimePicker.dateValue,
            lunchTime: lunchTimePicker.dateValue,
            scrumTime: scrumTimePicker.dateValue,
            minSleepDuration: minSleepDurationTimePicker.dateValue,
            minCodeRevDuration: minCodeRevDurationTimePicker.dateValue,
            codeRevLink: codeReviewsLinkTextField.stringValue,
            minWasteDuration: minWasteDurationTimePicker.dateValue,
            wasteLinks: wastedTimeLinksTextField.stringValue.components(separatedBy: ",")
        )
        presenter!.saveAppSettings(settings)
        
        appWireframe!.flipToTasksController()
	}
    
    @IBAction func handleAutoTrackButton (_ sender: NSButton) {
        autotrackingModeSegmentedControl.isEnabled = sender.state == NSOnState
    }
    
    @IBAction func handleBackupButton (_ sender: NSButton) {
        presenter!.enabledBackup(sender.state == NSOnState)
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
        
        // Tracking
        
        butAutotrack.state = settings.autotrack ? NSOnState : NSOffState
        autotrackingModeSegmentedControl.selectedSegment = settings.autotrackingMode.rawValue
        minSleepDurationTimePicker.dateValue = settings.minSleepDuration
        butTrackStartOfDay.state = settings.trackStartOfDay ? NSOnState : NSOffState
        butTrackLunch.state = settings.trackLunch ? NSOnState : NSOffState
        butTrackScrum.state = settings.trackScrum ? NSOnState : NSOffState
        
        startOfDayTimePicker.dateValue = settings.startOfDayTime
        endOfDayTimePicker.dateValue = settings.endOfDayTime
        lunchTimePicker.dateValue = settings.lunchTime
        scrumTimePicker.dateValue = settings.scrumTime
        
        // Extensions
        
        butTrackCodeReviews.state = settings.trackCodeReviews ? NSOnState : NSOffState
        butTrackWastedTime.state = settings.trackWastedTime ? NSOnState : NSOffState
        codeReviewsLinkTextField.stringValue = settings.codeRevLink
        wastedTimeLinksTextField.stringValue = settings.wasteLinks.joined(separator: ",")
        minCodeRevDurationTimePicker.dateValue = settings.minCodeRevDuration
        minWasteDurationTimePicker.dateValue = settings.minWasteDuration
        
        // Generic
        
        butBackup.state = settings.enableBackup ? NSOnState : NSOffState
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        butEnableLaunchAtStartup.state = enabled ? NSOnState : NSOffState
    }
    
}
