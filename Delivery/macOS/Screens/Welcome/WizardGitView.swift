//
//  WizardGitView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class WizardGitView: NSView {
    
    @IBOutlet var butSelectProject: NSButton!
    @IBOutlet var butSkip: NSButton!
    var onSkip: (() -> Void)?
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        onSkip?()
    }
}
