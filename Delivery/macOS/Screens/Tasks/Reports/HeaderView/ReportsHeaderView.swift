//
//  ReportsHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class ReportsHeaderView: NSTableHeaderView {
    
    @IBOutlet private var butPercents: NSButton!
    @IBOutlet private var butRound: NSButton!
    @IBOutlet private var totalTimeTextField: NSTextField!
    internal let pref = RCPreferences<LocalPreferences>()
    
    var didChangeSettings: (() -> Void)?
    // In hours
    var workedTime: String {
        get {
            return ""
        }
        set {
            totalTimeTextField.stringValue = newValue
        }
    }
    var workdayTime: Double {
        get {
            return 0.0
        }
        set {
            butRound.title = "Round to \(newValue) hours"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        butPercents.title = "Show time in percents"
        butPercents.state = pref.bool(.usePercents) ? .on : .off
        
        butRound.state = pref.bool(.enableRoundingDay) ? .on : .off
        butRound.toolTip = "This can be set in 'Settings/Tracking/Working between'"
    }

    override func draw (_ dirtyRect: NSRect) {
    }
    
    override func headerRect(ofColumn column: Int) -> NSRect {
        // This will prevent for a label to appear  in the middle of the header
        return NSRect.zero
    }
}

extension ReportsHeaderView {
    
    @IBAction func handleRoundButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .enableRoundingDay)
        didChangeSettings?()
    }
    
    @IBAction func handlePercentsButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .usePercents)
        didChangeSettings?()
    }
}
