//
//  CellProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 10/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

protocol CellProtocol {

	var statusImage: NSImageView? {get}
	var data: TaskCreationData {get set}
	var duration: String {get set}
    var isDark: Bool {get set}
    var isEditable: Bool {get set}
    var isRemovable: Bool {get set}
    var isIgnored: Bool {get set}
    var color: NSColor {get set}
    var timeToolTip: String? {get set}
	
	var didClickEditCell: ((_ cell: CellProtocol) -> ())? {get set}
	var didClickRemoveCell: ((_ cell: CellProtocol) -> ())? {get set}
	var didClickAddCell: ((_ cell: CellProtocol) -> ())? {get set}
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())? {get set}
}
