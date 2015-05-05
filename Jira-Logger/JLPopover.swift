//
//  Panel.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

public class JLPopover: NSPopover {
	
	public override init() {
		super.init()
	}

	required public init?(coder: NSCoder) {
		super.init()
	}
	
	override public func awakeFromNib() {
		
	}
	
	public func canBecomeKeyWindow() -> Bool {
		return true; // Allow Search field to become the first responder
	}
}
