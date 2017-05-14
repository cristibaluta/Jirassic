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
        
        presenter!.checkExtensions()
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
            wasteLinks: wastedTimeLinksTextField.stringValue.toArray()
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
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            jirassicImageView.image = NSImage(named: compatible ? NSImageNameStatusAvailable : NSImageNameStatusPartiallyAvailable)
            jirassicTextField.stringValue = compatible ? "Run 'jirassic' in Terminal for more info" : "Shell support script installed but jirassic cmd is outdated"
        } else {
            jirassicImageView.image = NSImage(named: NSImageNameStatusUnavailable)
            jirassicTextField.stringValue = "Not installed yet"
        }
        butInstallJirassic.isHidden = scriptInstalled
    }
    
    func setJitStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            jitImageView.image = NSImage(named: compatible ? NSImageNameStatusAvailable : NSImageNameStatusPartiallyAvailable)
            jitTextField.stringValue = compatible ? "Commit to git with Jit. Run 'jit' in Terminal for more info" : "Shell support script installed but jit cmd is outdated or not installed"
        } else {
            jitImageView.image = NSImage(named: NSImageNameStatusUnavailable)
            jitTextField.stringValue = "Not installed yet"
        }
        butInstallJit.isHidden = scriptInstalled
    }
    
    func setCodeReviewStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            coderevImageView.image = NSImage(named: compatible ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
            coderevTextField.stringValue = compatible ? "Time spent in stash is tracked as code review" : "Shell support script installed but outdated"
        } else {
            coderevImageView.image = NSImage(named: NSImageNameStatusUnavailable)
            coderevTextField.stringValue = "Not installed yet"
        }
        butInstallCoderev.isHidden = scriptInstalled
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
        wastedTimeLinksTextField.stringValue = settings.wasteLinks.toString()
        minCodeRevDurationTimePicker.dateValue = settings.minCodeRevDuration
        minWasteDurationTimePicker.dateValue = settings.minWasteDuration
        
        // Generic
        
        butBackup.state = settings.enableBackup ? NSOnState : NSOffState
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        butEnableLaunchAtStartup.state = enabled ? NSOnState : NSOffState
    }
    
}
