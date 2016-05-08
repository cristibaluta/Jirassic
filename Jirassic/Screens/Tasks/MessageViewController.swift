//
//  NoTasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

typealias MessageViewModel = (title: String?, message: String?, buttonTitle: String?)

class MessageViewController: NSViewController {

    @IBOutlet private var titleLabel: NSTextField?
    @IBOutlet private var messageLabel: NSTextField?
    @IBOutlet private var button: NSButton?
	
	var didPressButton: (() -> ())?
	
    var viewModel: MessageViewModel? {
        didSet {
            if let title = viewModel?.title {
                self.titleLabel?.stringValue = title
            }
            if let message = viewModel?.message {
                self.messageLabel?.stringValue = message
            }
            if let buttonTitle = viewModel?.buttonTitle {
                button?.hidden = false
                self.button?.title = buttonTitle
            } else {
                button?.hidden = true
            }
        }
    }
	
	// MARK: Actions
	
	@IBAction func handleStartButton (sender: NSButton) {
		self.didPressButton?()
	}
}
