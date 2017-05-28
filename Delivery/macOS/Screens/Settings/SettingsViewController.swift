//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet fileprivate var tabView: NSTabView!
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
        
        #if !APPSTORE
            butBackup.isEnabled = false
            butBackup.state = NSOffState
            butEnableLaunchAtStartup.isEnabled = false
            butEnableLaunchAtStartup.state = NSOffState
        #endif
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
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
    }
    
    deinit {
        RCLog("deinit")
    }
	
	
	// MARK: Actions
    
    @IBAction func handleInstallJitButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared().open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
//            presenter?.installJit()
            NSWorkspace.shared().open( URL(string: "https://github.com/ralcr/Jit")!)
        #endif
    }
    
    @IBAction func handleInstallJirassicButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared().open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
//            presenter?.installJirassic()
            NSWorkspace.shared().open( URL(string: "http://www.jirassic.com/#extensions")!)
        #endif
    }
    
	@IBAction func handleSaveButton (_ sender: NSButton) {
		
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
            jirassicTextField.stringValue = compatible ? "Run 'jirassic' in Terminal for more info" : "Applescript installed but jirassic cmd is outdated/uninstalled"
        } else {
            jirassicImageView.image = NSImage(named: NSImageNameStatusUnavailable)
            jirassicTextField.stringValue = "Not installed yet"
        }
        butInstallJirassic.isHidden = scriptInstalled && compatible
    }
    
    func setJitStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            jitImageView.image = NSImage(named: compatible ? NSImageNameStatusAvailable : NSImageNameStatusPartiallyAvailable)
            jitTextField.stringValue = compatible ? "Commits made with Jit will log time to Jirassic. Run 'jit' in Terminal for more info" : "Applescript installed but jit cmd is outdated/uninstalled"
        } else {
            jitImageView.image = NSImage(named: NSImageNameStatusUnavailable)
            jitTextField.stringValue = "Not installed yet"
        }
        butInstallJit.isHidden = scriptInstalled && compatible
    }
    
    func setCodeReviewStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            coderevImageView.image = NSImage(named: compatible ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
            coderevTextField.stringValue = compatible ? "Jirassic can read the url of your browser and it will log time based on it" : "Applescript installed but outdated"
        } else {
            coderevImageView.image = NSImage(named: NSImageNameStatusUnavailable)
            coderevTextField.stringValue = "Not installed yet"
        }
        butInstallCoderev.isHidden = scriptInstalled && compatible
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
    
    func enabledBackup (_ enabled: Bool, title: String) {
        butBackup.state = enabled ? NSOnState : NSOffState
        butBackup.title = title
    }
    
    func selectTab (atIndex index: Int) {
        tabView.selectTabViewItem(at: index)
    }
}

extension SettingsViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        RCPreferences<LocalPreferences>().set(tabViewItem?.label == "Tracking" ? 0 : 1, forKey: .settingsActiveTab)
    }
}
