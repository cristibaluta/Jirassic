//
//  CommitResult.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

// Git commit read from the command line
struct GitCommit {
    
    var commitNumber: String
    var date: Date
    var authorEmail: String
    var message: String
    var branchName: String?
}
