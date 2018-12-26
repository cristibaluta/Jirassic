//
//  BrowserCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class BrowserCell: NSTableRowView {

    static let height = CGFloat(270)
    
    @IBOutlet private var coderevImageView: NSImageView!
    @IBOutlet private var coderevTextField: NSTextField!
    @IBOutlet private var butInstallCoderev: NSButton!
    @IBOutlet private var butTrackCodeReviews: NSButton!
    @IBOutlet private var butTrackWastedTime: NSButton!
    @IBOutlet private var codeReviewsLinkTextField: NSTextField!
    @IBOutlet private var minCodeRevDurationLabel: NSTextField!
    @IBOutlet private var minCodeRevDurationSlider: NSSlider!
    @IBOutlet private var wastedTimeLinksTextField: NSTextField!
    @IBOutlet private var minWasteDurationLabel: NSTextField!
    @IBOutlet private var minWasteDurationSlider: NSSlider!
    
    func showSettings (_ settings: SettingsBrowser) {

        butTrackCodeReviews.state = settings.trackCodeReviews ? NSControl.StateValue.on : NSControl.StateValue.off
        butTrackWastedTime.state = settings.trackWastedTime ? NSControl.StateValue.on : NSControl.StateValue.off
        codeReviewsLinkTextField.stringValue = settings.codeRevLink
        wastedTimeLinksTextField.stringValue = settings.wasteLinks.toString()
        minCodeRevDurationSlider.integerValue = settings.minCodeRevDuration
        minWasteDurationSlider.integerValue = settings.minWasteDuration
        handleMinCodeRevDuration( minCodeRevDurationSlider )
        handleMinWasteDuration( minWasteDurationSlider )
        enableCodeReview( settings.trackCodeReviews )
        enableWastedTime( settings.trackWastedTime )
    }

    func settings() -> SettingsBrowser {
        return SettingsBrowser(
            trackCodeReviews: butTrackCodeReviews.state == NSControl.StateValue.on,
            trackWastedTime: butTrackWastedTime.state == NSControl.StateValue.on,
            minCodeRevDuration: minCodeRevDurationSlider.integerValue,
            codeRevLink: codeReviewsLinkTextField.stringValue,
            minWasteDuration: minWasteDurationSlider.integerValue,
            wasteLinks: wastedTimeLinksTextField.stringValue.toArray()
        )
    }

    func save() {

    }
    
    func setBrowserStatus (compatibility: Compatibility) {
        
        if compatibility.available {
            coderevImageView.image = NSImage(named: compatibility.compatible
                ? NSImage.statusAvailableName
                : NSImage.statusUnavailableName)
            coderevTextField.stringValue = compatibility.compatible
                ? "Jirassic can read the url of your browser and it will log time based on it"
                : (compatibility.available
                    ? "Browser support installed but outdated, please update!"
                    : "Browser support not installed, please install!")
        } else {
            coderevImageView.image = NSImage(named: NSImage.statusUnavailableName)
            coderevTextField.stringValue = "Not installed yet"
        }
        butInstallCoderev.isHidden = compatibility.available && compatibility.compatible
    }
    
    func enableCodeReview (_ enable: Bool) {
        codeReviewsLinkTextField.isEnabled = enable
        minCodeRevDurationSlider.isEnabled = enable
    }

    func enableWastedTime (_ enable: Bool) {
        wastedTimeLinksTextField.isEnabled = enable
        minWasteDurationSlider.isEnabled = enable
    }

    @IBAction func handleCodeReviewButton (_ sender: NSButton) {
        enableCodeReview(sender.state == NSControl.StateValue.on)
    }

    @IBAction func handleWastedTimeButton (_ sender: NSButton) {
        enableWastedTime(sender.state == NSControl.StateValue.on)
    }

    @IBAction func handleInstallBrowserSupportButton (_ sender: NSButton) {
        NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
    }

    @IBAction func handleMinCodeRevDuration (_ sender: NSSlider) {
        minCodeRevDurationLabel.stringValue = "\(sender.integerValue) min"
    }

    @IBAction func handleMinWasteDuration (_ sender: NSSlider) {
        minWasteDurationLabel.stringValue = "\(sender.integerValue) min"
    }
}
