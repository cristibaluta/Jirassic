//
//  Jira+Projects.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

extension JiraRepository {
    
    // GET https://.../rest/api/2/project
    // Returns an array of projects
    func fetchProjects (completion: @escaping (([JProject]) -> Void)) {
        
        let path = "rest/api/2/project"
        request?.get(at: path, success: { (response) in
            
            if let projects = response as? [[String: Any]] {
                var jprojects: [JProject] = []
                for project in projects {
                    let jproject = JProject(id: project["id"] as? String ?? "",
                                            key: project["key"] as? String ?? "",
                                            name: project["name"] as? String ?? "",
                                            url: project["self"] as? String ?? "")
                    jprojects.append(jproject)
                }
                completion(jprojects)
            } else {
                completion([])
            }
            
        }, failure: { (err) in
            completion([])
        })
    }
    
    // GET https://.../rest/api/2/search?jql=project=PROJECT_KEY&fields=*none&maxResults=-1
    // Returns a dictionary that includes an array of issues
    func fetchProjectIssues (projectKey: String, completion: @escaping (([JProjectIssue]) -> Void)) {
        
        let path = "rest/api/2/search?jql=project=\(projectKey)&fields=*none&maxResults=-1"
        request?.get(at: path, success: { (response) in
            
            if let response = response as? [String: Any], let issues = response["issues"] as? [[String: Any]] {
                var jissues: [JProjectIssue] = []
                for issue in issues {
                    let jissue = JProjectIssue(id: issue["id"] as? String ?? "",
                                               key: issue["key"] as? String ?? "",
                                               url: issue["self"] as? String ?? "")
                    jissues.append(jissue)
                }
                completion(jissues)
            } else {
                completion([])
            }
            
        }, failure: { (err) in
            completion([])
        })
    }
}
