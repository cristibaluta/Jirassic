//
//  ParseGitBranch.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class ParseGitBranch {
    
    fileprivate let taskIdEreg = "(([A-Z])+-([0-9])+)"
    fileprivate let branchFromGitLogEreg = "origin(/([A-Za-z0-9_-])+)"
    fileprivate let branchFromGitMergeEreg = "from ([A-Za-z0-9_-])+ to"
    
    var branchName: String
    
    init(branchName: String) {
        
        self.branchName = branchName
        
        if let branch = self.parseGitLog(branchName) {
            self.branchName = branch
        }
        else if let branch = self.parseGitMerge(branchName) {
            self.branchName = branch
        }
    }
    
    private func parseGitLog(_ branchName: String) -> String? {
        
        guard let regex = try? NSRegularExpression(pattern: self.branchFromGitLogEreg, options: []) else {
            return nil
        }
        let match = regex.firstMatch(in: branchName, options: [], range: NSRange(location: 0, length: branchName.count))
        if let match = match {
            return (branchName as NSString).substring(with: match.range)
                    .replacingOccurrences(of: "origin/", with: "")
        }
        return nil
    }
    
    private func parseGitMerge(_ branchName: String) -> String? {
        
        guard let regex = try? NSRegularExpression(pattern: self.branchFromGitMergeEreg, options: []) else {
            return nil
        }
        let match = regex.firstMatch(in: branchName, options: [], range: NSRange(location: 0, length: branchName.count))
        if let match = match {
            return (branchName as NSString).substring(with: match.range)
                    .replacingOccurrences(of: "from ", with: "")
                    .replacingOccurrences(of: " to", with: "")
        }
        return nil
    }
    
    // Extracts from the branch name the taskNumber if exists
    func taskNumber() -> String? {
        
        var taskNumber: String? = nil
        guard let regex = try? NSRegularExpression(pattern: self.taskIdEreg, options: []) else {
            return taskNumber
        }
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
            .trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
