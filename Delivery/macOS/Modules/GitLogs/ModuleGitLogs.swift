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
    
    func logs (on date: Date, completion: @escaping (([Task]) -> Void)) {
        
        var tasks = [Task]()
        
        let paths = localPreferences.string(.settingsGitPaths).split(separator: ",").map { String($0) }
        logs(on: date, paths: paths, previousCommits: []) { commits in
            
            for commit in commits {
                let task = Task(lastModifiedDate: nil,
                                startDate: nil,
                                endDate: commit.date,
                                notes: commit.message,
                                taskNumber: nil,
                                taskTitle: nil,
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
            commits += parser.toGitCommits()
            
            self.logs(on: date, paths: paths, previousCommits: commits, completion: completion)
            
        })
    }
}
