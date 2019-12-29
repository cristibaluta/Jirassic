//
//  MonthReportsHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class MonthReportsHeaderView: ReportsHeaderView {
    
    @IBOutlet private var butCopyAll: NSButton!
    @IBOutlet private var butCopyAsHtml: NSButton!
    @IBOutlet private var totalDaysTextField: NSTextField!
    var didClickCopyAll: ((Bool) -> Void)?
    
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
    }
}

extension MonthReportsHeaderView {
    
    @IBAction func handleCopyAllButton (_ sender: NSButton) {
        didClickCopyAll?(pref.bool(.copyWorklogsAsHtml))
    }
    
    @IBAction func handleHtmlButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .copyWorklogsAsHtml)
    }
}
