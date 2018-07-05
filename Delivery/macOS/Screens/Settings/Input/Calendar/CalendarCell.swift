//
//  CalendarCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class CalendarCell: NSTableRowView {
    
    static let height = CGFloat(60)
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var statusTextField: NSTextField!
    @IBOutlet private var butAuthorize: NSButton!
    @IBOutlet private var butEnable: NSButton!
    
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
}
