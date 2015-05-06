//
//  NewTaskViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
	
	var onOptionChosen: ((i: Int) -> Void)?
	
	class func instanceFromStoryboard() -> NewTaskViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("NewTaskViewController") as! NewTaskViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
