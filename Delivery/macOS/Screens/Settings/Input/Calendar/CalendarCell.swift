//
//  CalendarCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class CalendarCell: NSTableRowView {
    
    static let height = CGFloat(200)
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var statusTextField: NSTextField!
    @IBOutlet private var descriptionTextField: NSTextField!
    @IBOutlet private var butAuthorize: NSButton!
    @IBOutlet private var butEnable: NSButton!
    @IBOutlet private var scrollView: NSScrollView!
    private var calendarsButtons = [NSButton]()
    
    private var  presenter: CalendarAppPresenterInput = CalendarAppPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        (presenter as! CalendarAppPresenter).userInterface = self
        presenter.refresh()
    }
    
    func save() {
        // Nothing to save
    }
    
    @IBAction func handleAuthorizeButton (_ sender: NSButton) {
        presenter.authorize()
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        presenter.enable(sender.state == .on)
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

extension CalendarCell: CalendarAppPresenterOutput {
    
    func enable (_ enabled: Bool) {
        for but in calendarsButtons {
            but.isEnabled = enabled
        }
    }
    
    func setStatusImage (_ imageName: NSImage.Name) {
        statusImageView.image = NSImage(named: imageName)
    }
    
    func setStatusText (_ text: String) {
        statusTextField.stringValue = text
    }
    
    func setDescriptionText (_ text: String) {
        descriptionTextField.stringValue = text
    }
    
    func setCalendarStatus (authorized: Bool, enabled: Bool) {
        statusImageView.isHidden = authorized
        butAuthorize.isHidden = authorized
        butEnable.isHidden = !authorized
        butEnable.state = enabled ? .on : .off
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
