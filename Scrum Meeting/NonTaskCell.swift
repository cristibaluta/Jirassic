//
//  NonTaskCell.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 15/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class NonTaskCell: UITableViewCell {
	
	@IBOutlet var circleWhite: UIView?
	@IBOutlet var circleDark: UIView?
	@IBOutlet var dateLabel: UILabel?
	@IBOutlet var notesBackgroundView: UIView?
	@IBOutlet var notesLabel: UILabel?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		circleWhite?.layer.cornerRadius = circleWhite!.frame.size.width/2
		circleDark?.layer.cornerRadius = circleDark!.frame.size.width/2
		notesBackgroundView?.layer.cornerRadius = circleDark!.frame.size.width/2
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
