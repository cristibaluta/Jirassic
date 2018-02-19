//
//  GitBranchParser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class GitBranchParser {
    
    private var raw: String
    
    init (raw: String) {
        self.raw = raw
    }
    
//    func toGitCommits() -> [GitCommit] {
//        // "50cfe7b2 Merge pull request #567 in BSEAPP/bsa-ios from APP-3007__User_Accept_of_Declaration_of_consent_for_Fitness to master"
//        var commits = [GitCommit]()
//        
//        let r = raw.replacingOccurrences(of: "\r", with: "\n")
//        let results = r.split(separator: "\n").map { String($0) }
//        
//        
//        return commits
//    }
}
