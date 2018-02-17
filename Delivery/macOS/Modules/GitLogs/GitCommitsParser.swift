//
//  GitCommitsParser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class GitCommitsParser {
    
    private var raw: String
    
    init (raw: String) {
        self.raw = raw
    }
    
    func toGitCommits() -> [GitCommit] {
        
        var commits = [GitCommit]()
        
        let r = raw.replacingOccurrences(of: "\r", with: "\n")
        let results = raw.split(separator: "\n").map { String($0) }
        for result in results {
            if result != "" {
                commits.append( self.parseCommit(result) )
            }
        }
        
        return commits
    }
    
    private func parseCommit (_ commit: String) -> GitCommit {
        
        var comps = commit.split(separator: ";").map { String($0) }
        let timestamp = comps.count > 0 ? comps.removeFirst() : "0"
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp)!)
        let email = comps.count > 0 ? comps.removeFirst() : ""
        let message = comps.count > 0 ? comps.removeFirst() : ""
        let branchName = comps.count > 0 ? comps.removeFirst() : ""
        
        return GitCommit(date: date,
                         authorEmail: email,
                         message: message,
                         branchName: branchName)
    }
}
