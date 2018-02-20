//
//  ModuleGitLogs.swift
//  Jirassic
//
//  Created by Cristian Baluta on 16/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class ModuleGitLogs {
    
    private let extensions = ExtensionsInteractor()
    private let localPreferences = RCPreferences<LocalPreferences>()
    
    func isGitInstalled (completion: @escaping (Bool) -> Void) {
        extensions.checkIfGitInstalled(completion: completion)
    }
    
    func logs (on date: Date, completion: @escaping (([Task]) -> Void)) {
        
        var tasks = [Task]()
        
        let paths = localPreferences.string(.settingsGitPaths).split(separator: ",").map { String($0) }
        logs(on: date, paths: paths, previousCommits: []) { commits in
            
            for commit in commits {
                let task = Task(lastModifiedDate: nil,
                                startDate: nil,
                                endDate: commit.date,
                                notes: commit.message,
                                taskNumber: nil,//todo: obtain task number from branch name
                                taskTitle: commit.branchName,
                                taskType: .gitCommit,
                                objectId: String.random())
                tasks.append(task)
            }
            completion(tasks)
            
        }
    }
    
    private func logs (on date: Date, paths: [String], previousCommits: [GitCommit], completion: @escaping (([GitCommit]) -> Void)) {
        
        var commits = previousCommits
        var paths = paths
        
        guard let path = paths.first else {
            completion(commits)
            return
        }
        paths.removeFirst()
        
        extensions.getGitLogs(at: path, date: date, completion: { rawResults in
            
            let parser = GitCommitsParser(raw: rawResults)
            let rawCommits = parser.toGitCommits()
            
            // Obtain branch names where missing
            self.getBranchName(at: path, previousCommits: rawCommits, completion: { commitsWithBranches in
                commits += commitsWithBranches
                self.logs(on: date, paths: paths, previousCommits: commits, completion: completion)
            })
            
        })
    }
    
    private func getBranchName (at path: String, previousCommits: [GitCommit], completion: @escaping (([GitCommit]) -> Void)) {
        
        var i: Int = -1, j = 0
        var commits = previousCommits
        for c in commits {
            if c.branchName == nil {
                i = j
                break
            }
            j += 1
        }
        if i > -1 {
            var commitToFix = commits[i]
            extensions.getGitBranch(at: path, containing: commitToFix.commitNumber, completion: { rawBranches in
                commitToFix.branchName = GitBranchParser(raw: rawBranches).branchName()
                commits[i] = commitToFix
                self.getBranchName(at: path, previousCommits: commits, completion: completion)
            })
        } else {
            completion(commits)
        }
    }
}
