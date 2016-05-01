//
//  TaskCellProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 10/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

protocol TaskCellProtocol: NSObjectProtocol {

	var statusImage: NSImageView? {get}
	var data: TaskCreationData {get set}
	var duration: String {get set}
	
	var didEndEditingCell: ((cell: TaskCellProtocol) -> ())? {get set}
	var didRemoveCell: ((cell: TaskCellProtocol) -> ())? {get set}
	var didAddCell: ((cell: TaskCellProtocol) -> ())? {get set}
	var didCopyContentCell: ((cell: TaskCellProtocol) -> ())? {get set}
}