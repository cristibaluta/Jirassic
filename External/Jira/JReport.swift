//
//  JReport.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/07/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

struct JReport {
    
    var comment: String
    var dateStarted: String//YYYY-MM-ddT00:00:00.000+0000
    var timeSpentSeconds: Int
//    var author: JAuthor
//    var issue: JIssue
    var workAttributeValues: [JWorkAttribute]
}
