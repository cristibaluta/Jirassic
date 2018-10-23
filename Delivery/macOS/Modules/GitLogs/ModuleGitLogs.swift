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
    
//    func isReachable (completion: @escaping (Bool) -> Void) {
//        checkIfGitInstalled(completion: completion)
//    }
    
    func logs (dateStart: Date, dateEnd: Date, completion: @escaping (([Task]) -> Void)) {
        // Because of a bug in applescripts split the call into smaller chunks for months
        if dateEnd.timeIntervalSince(dateStart) > 7*24.hoursToSec {
            let chunks = ceil(dateEnd.timeIntervalSince(dateStart) / (7*24.hoursToSec))
            var dates = [(dateStart: Date, dateEnd: Date)]()
            for i in 0..<Int(chunks) {
                var date = (dateStart: dateStart.addingTimeInterval(Double(i*7)*24.hoursToSec),
                            dateEnd: dateStart.addingTimeInterval(Double((i+1)*7)*24.hoursToSec))
                if date.dateEnd > dateEnd {
                    date.dateEnd = dateEnd
                }
                dates.append(date)
            }
            logsChunk(dates: dates, completion: completion)
        } else {
            logsChunk(dates: [(dateStart: dateStart, dateEnd: dateEnd)], completion: completion)
        }
    }

    private func logsChunk (dates: [(dateStart: Date, dateEnd: Date)], previousTasks: [Task] = [], completion: @escaping (([Task]) -> Void)) {

        var tasks = previousTasks
        var dates = dates
        guard dates.count > 0 else {
            completion(tasks)
            return
        }
        let interval = dates.removeFirst()
        
        let paths = localPreferences.string(.settingsGitPaths).split(separator: ",").map { String($0) }
        logs(dateStart: interval.dateStart, dateEnd: interval.dateEnd, paths: paths, previousCommits: []) { commits in
            for commit in commits {
                let str = commit.branchName != "" ? commit.branchName : commit.message
                let branchParser = ParseGitBranch(branchName: str ?? "")
                let taskTitle = branchParser.taskTitle()
                let taskNumber = branchParser.taskNumber() ?? taskTitle
                // Remove task number from the beginning of a commit message
                let message = commit.message.replacingOccurrences(of: taskNumber, with: "").trimmingCharacters(in: NSCharacterSet.whitespaces)
                
                let task = Task(lastModifiedDate: nil,
                                startDate: nil,
                                endDate: commit.date,
                                notes: message,
                                taskNumber: taskNumber,
                                taskTitle: taskTitle,
                                taskType: .gitCommit,
                                objectId: String.random())
                tasks.append(task)
            }
            self.logsChunk(dates: dates, previousTasks: tasks, completion: completion)
            
        }
    }
    
    private func logs (dateStart: Date, dateEnd: Date, paths: [String], previousCommits: [GitCommit], completion: @escaping (([GitCommit]) -> Void)) {
        
        var commits = previousCommits
        var paths = paths
        
        guard let path = paths.first else {
            completion(commits)
            return
        }
        paths.removeFirst()
        
        let allowedAuthors: [String] = localPreferences.string(.settingsGitAuthors).split(separator: ",").map { String($0) }
        
        getGitLogs(at: path, dateStart: dateStart, dateEnd: dateEnd, completion: { rawResults in
            
            let parser = GitCommitsParser(raw: rawResults)
            var rawCommits: [GitCommit] = parser.toGitCommits()
            // Filter out commits that don't belong to my users
            rawCommits = rawCommits.filter({ allowedAuthors.contains($0.authorEmail) })
            
            // Obtain branch names where missing
            // 1)

            // 2) 
            self.getBranchName(at: path, previousCommits: rawCommits, completion: { commitsWithBranches in
                commits += commitsWithBranches
                self.logs(dateStart: dateStart, dateEnd: dateEnd, paths: paths, previousCommits: commits, completion: completion)
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
            getGitBranch(at: path, containing: commitToFix.commitNumber, completion: { rawBranches in
                let parser = GitBranchParser(raw: rawBranches)
                commitToFix.branchName = parser.firstBranchName()
                commits[i] = commitToFix
                self.getBranchName(at: path, previousCommits: commits, completion: completion)
            })
        } else {
            completion(commits)
        }
    }
}

extension ModuleGitLogs {
    
    func checkIfGitInstalled (completion: @escaping (Bool) -> Void) {
        
        let command = "command -v git"// Returns the path to git if exists
        extensions.run (command: command, completion: { result in
            completion(result != nil)
        })
    }
    
//    private func checkGitRepository (at path: String, completion: @escaping (Bool) -> Void) {
//
//        let command = "git -C \(path) rev-parse --is-inside-work-tree"
//        extensions.run (command: command, completion: { result in
//            completion(result == "true")
//        })
//    }
    
    private func getGitLogs (at path: String, dateStart: Date, dateEnd: Date, completion: @escaping (String) -> Void) {
        // https://www.kernel.org/pub/software/scm/git/docs/git-log.html#_pretty_formats
        // error "fatal: Not a git repository (or any of the parent directories): .git" number 128
        // do shell script git -C ~/Documents/proj log --after="2018-2-6" --before="2018-2-7" --pretty=format:"%at;%ae;%s;%D"
        
        let startDate = dateStart.YYYYMMddT00()
        let endDate = dateEnd.YYYYMMddT00()
        let command = "git -C \(path) log --reflog --after=\"\(startDate)\" --before=\"\(endDate)\" --pretty=format:\"%h;%at;%ae;%s;%D\""
        extensions.run (command: command, completion: { result in
            if let result = result {
                if result.contains("fatal: Not a git repository (or any of the parent directories): .git") {
                    completion("")
                } else {
                    completion(result)
                }
            } else {
                completion("")
            }
        })
    }
    
    private func getGitBranch (at path: String, containing commitNumber: String, completion: @escaping (String) -> Void) {
        
        // let command = "git -C \(path) log \(commitNumber)..HEAD --ancestry-path --merges --oneline | tail -n 1"
        let command = "git -C \(path) branch --contains \(commitNumber)"
        extensions.run (command: command, completion: { result in
            if let result = result {
                completion(result)
            } else {
                completion("")
            }
        })
    }
}
