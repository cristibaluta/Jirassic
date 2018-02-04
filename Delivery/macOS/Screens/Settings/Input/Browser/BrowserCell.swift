//
//  BrowserCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class BrowserCell: NSTableRowView {

    @IBOutlet fileprivate var coderevImageView: NSImageView!
    @IBOutlet fileprivate var coderevTextField: NSTextField!
    @IBOutlet fileprivate var butInstallCoderev: NSButton!
    @IBOutlet fileprivate var butTrackCodeReviews: NSButton!
    @IBOutlet fileprivate var butTrackWastedTime: NSButton!
    @IBOutlet fileprivate var codeReviewsLinkTextField: NSTextField!
    @IBOutlet fileprivate var minCodeRevDurationLabel: NSTextField!
    @IBOutlet fileprivate var minCodeRevDurationSlider: NSSlider!
    @IBOutlet fileprivate var wastedTimeLinksTextField: NSTextField!
    @IBOutlet fileprivate var minWasteDurationLabel: NSTextField!
    @IBOutlet fileprivate var minWasteDurationSlider: NSSlider!
    
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func showSettings (_ settings: SettingsBrowser) {

        butTrackCodeReviews.state = settings.trackCodeReviews ? NSControl.StateValue.on : NSControl.StateValue.off
        butTrackWastedTime.state = settings.trackWastedTime ? NSControl.StateValue.on : NSControl.StateValue.off
        codeReviewsLinkTextField.stringValue = settings.codeRevLink
        wastedTimeLinksTextField.stringValue = settings.wasteLinks.toString()
        minCodeRevDurationSlider.integerValue = settings.minCodeRevDuration
        handleMinCodeRevDuration(minCodeRevDurationSlider)
        minWasteDurationSlider.integerValue = settings.minWasteDuration
        handleMinWasteDuration(minWasteDurationSlider)
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
    
    func setBrowserStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            coderevImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusUnavailable)
            coderevTextField.stringValue = compatible
                ? "Jirassic can read the url of your browser and it will log time based on it"
                : "Applescript installed but outdated"
        } else {
            coderevImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            coderevTextField.stringValue = "Not installed yet"
        }
        butInstallCoderev.isHidden = scriptInstalled && compatible
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
