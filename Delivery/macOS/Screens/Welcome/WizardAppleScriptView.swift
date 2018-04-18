//
//  WizardAppleScriptView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class WizardAppleScriptView: NSView {
    
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var subtitleLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    var onSkip: (() -> Void)?
    
    @IBAction func handleInstructionsButton (_ sender: NSButton) {
        #if APPSTORE
        NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
        //            presenter?.installJirassic()
        NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #endif
    }

    @IBAction func handleSkipButton (_ sender: NSButton) {
        onSkip?()
    }
}
