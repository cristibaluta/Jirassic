//
//  PlaceholderViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCLog

typealias MessageViewModel = (title: String?, message: String?, buttonTitle: String?)

class PlaceholderViewController: NSViewController {

    @IBOutlet fileprivate weak var titleLabel: NSTextField!
    @IBOutlet fileprivate weak var messageLabel: NSTextField!
    @IBOutlet fileprivate weak var button: NSButton!
	
	var didPressButton: (() -> ())?
	
    var viewModel: MessageViewModel? {
        
        didSet {
            guard self.titleLabel != nil else {
                fatalError("viewModel should be set after the VC is presented")
            }
            if let title = viewModel?.title {
                self.titleLabel?.stringValue = title
            }
            if let message = viewModel?.message {
                self.messageLabel?.stringValue = message
            }
            if let buttonTitle = viewModel?.buttonTitle {
                button?.isHidden = false
                self.button?.title = buttonTitle
            } else {
                button?.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PlaceholderViewController {
	
	@IBAction func handleStartButton (_ sender: NSButton) {
        RCLog(sender)
		self.didPressButton?()
	}
}
