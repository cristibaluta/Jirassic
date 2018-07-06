//
//  CalendarCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class CalendarCell: NSTableRowView {
    
    static let height = CGFloat(150)
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var statusTextField: NSTextField!
    @IBOutlet private var butAuthorize: NSButton!
    @IBOutlet private var butEnable: NSButton!
    private var calendarsButtons = [NSButton]()
    
    private var  presenter: CalendarPresenterInput = CalendarPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        (presenter as! CalendarPresenter).userInterface = self
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
}

extension CalendarCell: CalendarPresenterOutput {
    
    func setStatusImage (_ imageName: NSImage.Name) {
        statusImageView.image = NSImage(named: imageName)
    }
    
    func setStatusText (_ text: String) {
        statusTextField.stringValue = text
    }
    
    func setCalendarStatus (authorized: Bool, enabled: Bool) {
        butAuthorize.isHidden = authorized
        butEnable.isHidden = !authorized
        butEnable.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
    }

    func setCalendars (_ calendars: [String], selected: [String]) {

        var x = CGFloat(90)
        var y = CGFloat(103)
        for title in calendars {
            let but = NSButton()
            but.setButtonType(.switch)
            but.title = title
            but.sizeToFit()
            if x + but.frame.size.width > self.frame.size.width {
                y += 26
                x = 10
            }
            but.frame = CGRect(x: x, y: y, width: but.frame.size.width, height: but.frame.size.height)
            but.state = selected.contains(title) ? .on : .off
            but.target = self
            but.action = #selector(didClickCalendarButton)
            self.addSubview(but)

            x += but.frame.size.width + 10
        }
    }

    @objc func didClickCalendarButton (_ sender: NSButton) {
        if sender.state == .on {
            presenter.enableCalendar(sender.title)
        } else {
            presenter.disableCalendar(sender.title)
        }
    }
}
