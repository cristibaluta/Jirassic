//
//  GitCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class GitCell: NSTableRowView, Saveable {

    static let height = CGFloat(120)
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var butEnable: NSButton!
    @IBOutlet private var statusTextField: NSTextField!
    @IBOutlet private var descriptionTextField: NSTextField!
    @IBOutlet private var butInstall: NSButton!
    @IBOutlet private var butPurchase: NSButton!

    var presenter: GitPresenterInput = GitPresenter()
    var onPurchasePressed: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        (presenter as! GitPresenter).userInterface = self
        butEnable.isHidden = true
        butPurchase.isHidden = true
    }
    
    func save() {
        
    }
    
    @IBAction func handleInstallButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
            NSWorkspace.shared.open( URL(string: "https://github.com/ralcr/Jit")!)
        #endif
    }
    
    @IBAction func handlePurchaseButton (_ sender: NSButton) {
        onPurchasePressed?()
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        presenter.enableGit(sender.state == .on)
    }
}

extension GitCell: GitPresenterOutput {
    
    func setStatusImage (_ imageName: NSImage.Name) {
        statusImageView.image = NSImage(named: imageName)
    }
    func setStatusText (_ text: String) {
        statusTextField.stringValue = text
    }
    func setDescriptionText (_ text: String) {
        descriptionTextField.stringValue = text
    }
    func setButInstall (enabled: Bool) {
        butInstall.isHidden = !enabled
    }
    func setButPurchase (enabled: Bool) {
        butPurchase.isHidden = !enabled
    }
    func setButEnable (on: Bool?, enabled: Bool?) {
        if let isOn = on {
            butEnable.state = isOn ? .on : .off
        }
        butEnable.isHidden = enabled == false
    }
}
