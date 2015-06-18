//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	
	var handleSaveButton: (() -> ())?
	var handleCloseButton: (() -> ())?
	
	
	class func instanceFromStoryboard() -> SettingsViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("SettingsViewController") as! SettingsViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	
	// MARK: Actions
	
	@IBAction func handleSaveButton(sender: NSButton) {
		self.handleSaveButton!()
	}
	
}
