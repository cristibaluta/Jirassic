//
//  TrackingView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TrackingView: NSView {
    
    @IBOutlet fileprivate var butAutotrack: NSButton!
    @IBOutlet fileprivate var autotrackingModeSegmentedControl: NSSegmentedControl!
    @IBOutlet fileprivate var butTrackStartOfDay: NSButton!
    @IBOutlet fileprivate var butTrackLunch: NSButton!
    @IBOutlet fileprivate var butTrackScrum: NSButton!
//    @IBOutlet fileprivate var butTrackMeetings: NSButton!
    @IBOutlet fileprivate var startOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var endOfDayTimePicker: NSDatePicker!
    @IBOutlet fileprivate var lunchTimePicker: NSDatePicker!
    @IBOutlet fileprivate var scrumTimePicker: NSDatePicker!
    @IBOutlet fileprivate var minSleepDurationLabel: NSTextField!
    @IBOutlet fileprivate var minSleepDurationSlider: NSSlider!
    
    
    @IBAction func handleAutoTrackButton (_ sender: NSButton) {
        autotrackingModeSegmentedControl.isEnabled = sender.state == NSControl.StateValue.on
    }
    
    @IBAction func handleMinSleepDuration (_ sender: NSSlider) {
        minSleepDurationLabel.stringValue = "Ignore sleeps shorter than \(sender.integerValue) minutes"
    }
    
    func showSettings (_ settings: SettingsTracking) {
        
        butAutotrack.state = settings.autotrack ? NSControl.StateValue.on : NSControl.StateValue.off
        autotrackingModeSegmentedControl.selectedSegment = settings.autotrackingMode.rawValue
        minSleepDurationSlider.integerValue = settings.minSleepDuration
        handleMinSleepDuration(minSleepDurationSlider)
        butTrackStartOfDay.state = settings.trackStartOfDay ? NSControl.StateValue.on : NSControl.StateValue.off
        butTrackLunch.state = settings.trackLunch ? NSControl.StateValue.on : NSControl.StateValue.off
        butTrackScrum.state = settings.trackScrum ? NSControl.StateValue.on : NSControl.StateValue.off
        
        startOfDayTimePicker.dateValue = settings.startOfDayTime
        endOfDayTimePicker.dateValue = settings.endOfDayTime
        lunchTimePicker.dateValue = settings.lunchTime
        scrumTimePicker.dateValue = settings.scrumTime
    }
    
    func settings() -> SettingsTracking {
        
        return SettingsTracking(
            
            autotrack: butAutotrack.state == NSControl.StateValue.on,
            autotrackingMode: TrackingMode(rawValue: autotrackingModeSegmentedControl.selectedSegment)!,
            trackLunch: butTrackLunch.state == NSControl.StateValue.on,
            trackScrum: butTrackScrum.state == NSControl.StateValue.on,
            trackMeetings: true,//butTrackMeetings.state == NSControl.StateValue.on,
            trackStartOfDay: butTrackStartOfDay.state == NSControl.StateValue.on,
            startOfDayTime: startOfDayTimePicker.dateValue,
            endOfDayTime: endOfDayTimePicker.dateValue,
            lunchTime: lunchTimePicker.dateValue,
            scrumTime: scrumTimePicker.dateValue,
            minSleepDuration: minSleepDurationSlider.integerValue
        )
    }
    
    func save() {
        
    }
}
