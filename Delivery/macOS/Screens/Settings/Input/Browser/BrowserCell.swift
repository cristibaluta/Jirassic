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
    @IBOutlet fileprivate var wastedTimeLinksTextField: NSTextField!
    
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func save() {

    }

    @IBAction func handleInstallBrowserSupportButton (_ sender: NSButton) {
        NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
    }

    @IBAction func handleAutoTrackButton (_ sender: NSButton) {
//        autotrackingModeSegmentedControl.isEnabled = sender.state == NSControl.StateValue.on
    }

    @IBAction func handleBackupButton (_ sender: NSButton) {
//        presenter!.enabledBackup(sender.state == NSControl.StateValue.on)
    }

    @IBAction func handleLaunchAtStartupButton (_ sender: NSButton) {
//        presenter!.enabledLaunchAtStartup(sender.state == NSControl.StateValue.on)
    }

    @IBAction func handleMinSleepDuration (_ sender: NSSlider) {
//        minSleepDurationLabel.stringValue = "Ignore sleeps shorter than \(sender.integerValue) minutes"
    }

    @IBAction func handleMinCodeRevDuration (_ sender: NSSlider) {
//        minCodeRevDurationLabel.stringValue = "\(sender.integerValue) min"
    }

    @IBAction func handleMinWasteDuration (_ sender: NSSlider) {
//        minWasteDurationLabel.stringValue = "\(sender.integerValue) min"
    }
}
