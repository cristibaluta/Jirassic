//
//  ParseGitBranch.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class ParseGitBranch {
    
    fileprivate let taskIdEreg = "([A-Z]+-[0-9])\\w+"
    
    var branchName: String
    
    init(branchName: String) {
        self.branchName = branchName
    }
    
    // Extracts from the branch name the taskNumber if exists
    func taskNumber() -> String? {
        
        var taskNumber: String? = nil
        let regex = try! NSRegularExpression(pattern: self.taskIdEreg, options: [])
        let match = regex.firstMatch(in: branchName, options: [], range: NSRange(location: 0, length: branchName.count))
        if let match = match {
            taskNumber = (branchName as NSString).substring(with: match.range)
        }
        
        return taskNumber
    }
    
    // Extracts from the branch name what is left after taskNumber is extracted, and dashes are removed
    func taskTitle() -> String {
        
        let taskNumber = self.taskNumber()
        return branchName.replacingOccurrences(of: taskNumber ?? "", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
    }
}
