//
//  NonTaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 15/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class NonTaskCell: UITableViewCell {
	
	@IBOutlet var dateLabel: UILabel?
	@IBOutlet var notesLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

    override func setSelected (_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
