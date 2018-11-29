//
//  WizardCalendarView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 15/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class WizardCalendarView: NSView {
    
    @IBOutlet private var scrollView: NSScrollView!
    @IBOutlet private var butAuthorize: NSButton!
    @IBOutlet var butSkip: NSButton!
    var onSkip: (() -> Void)?
    private let pref = RCPreferences<LocalPreferences>()
    private var calendarsButtons = [NSButton]()
    private var presenter: CalendarPresenterInput = CalendarPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        (presenter as! CalendarPresenter).userInterface = self
        (presenter as! CalendarPresenter).refresh()
    }
    
    func save() {
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        save()
        onSkip?()
    }
    
    @IBAction func handleAuthorizeButton (_ sender: NSButton) {
        // Enable the calendar so when it gets authorized will be able to read and display the list of calendars
        presenter.enable(true)
        presenter.authorize()
    }
    
    override func layout() {
        super.layout()
        
        var x = CGFloat(0)
        var y = CGFloat(0)
        for but in calendarsButtons {
            if x + but.frame.size.width > scrollView.frame.size.width {
                y += 26
                x = CGFloat(0)
            }
            but.frame = CGRect(x: x, y: y, width: but.frame.size.width, height: but.frame.size.height)
            x += but.frame.size.width + 10
        }
        scrollView.documentView?.setFrameSize(NSSize(width: 0, height: y + 26))
    }
}

extension WizardCalendarView: CalendarPresenterOutput {
    
    func enable (_ enabled: Bool) {
        butAuthorize.isHidden = enabled
    }
    
    func setStatusImage (_ imageName: NSImage.Name) {
    }
    
    func setStatusText (_ text: String) {
    }
    
    func setDescriptionText (_ text: String) {
    }
    
    func setCalendarStatus (authorized: Bool, enabled: Bool) {
    }
    
    func setCalendars (_ calendars: [String], selected: [String]) {
        
        for but in calendarsButtons {
            but.removeFromSuperview()
        }
        calendarsButtons = []
        
        for title in calendars {
            let but = NSButton()
            but.setButtonType(.switch)
            but.title = title
            but.sizeToFit()
            but.state = selected.contains(title) ? .on : .off
            but.target = self
            but.action = #selector(didClickCalendarButton)
            scrollView.addSubview(but)
            self.calendarsButtons.append(but)
        }
        self.needsLayout = true
    }
    
    @objc func didClickCalendarButton (_ sender: NSButton) {
        if sender.state == .on {
            presenter.enableCalendar(sender.title)
        } else {
            presenter.disableCalendar(sender.title)
        }
    }
}
