//
//  MonthReportsHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa
import RCPreferences

class CopyReportCell: NSTableRowView {
    
    @IBOutlet private var butCopyAll: NSButton!
    @IBOutlet private var butCopyAsHtml: NSButton!
    @IBOutlet private var totalDaysTextField: NSTextField!
    @IBOutlet private var backgroundView: NSVisualEffectView!
    @IBOutlet private var butPercents: NSButton!
    @IBOutlet private var butRound: NSButton!
    @IBOutlet private var totalTimeTextField: NSTextField!
    internal let pref = RCPreferences<LocalPreferences>()
    var didClickCopyAll: ((Bool) -> Void)?
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
    var numberOfDays: Int {
        get {
            return 0
        }
        set {
            totalDaysTextField.stringValue = "Number of days: \(newValue)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        butCopyAsHtml.state = pref.bool(.copyWorklogsAsHtml) ? .on : .off
        butCopyAsHtml.toolTip = "This can be set in 'Settings/Tracking/Working between'"

        butPercents.title = "Show time in percents"
        butPercents.state = pref.bool(.usePercents) ? .on : .off

        butRound.state = pref.bool(.enableRoundingDay) ? .on : .off
        butRound.toolTip = "This can be set in 'Settings/Tracking/Working between'"
    }
}

extension CopyReportCell {
    
    @IBAction func handleCopyAllButton (_ sender: NSButton) {
        didClickCopyAll?(pref.bool(.copyWorklogsAsHtml))
    }
    
    @IBAction func handleHtmlButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .copyWorklogsAsHtml)
    }

    @IBAction func handleRoundButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .enableRoundingDay)
        //didChangeSettings?()
    }

    @IBAction func handlePercentsButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .usePercents)
        //didChangeSettings?()
    }
}
