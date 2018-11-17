//
//  JiraRepository+Projects.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

extension JiraRepository {
    
    // GET https://.../rest/api/2/project
    // Returns an array of projects
    func fetchProjects (success: @escaping ([JProject]) -> Void, failure: @escaping (Error) -> Void) {
        
        let path = "rest/api/2/project"
        request?.get(at: path, success: { responseData in
            
            guard let responseJson = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments),
                let projects = responseJson as? [[String: Any]] else {
                failure(RCHttpError(errorDescription: "Invalid json response"))
                return
            }
            
            var jprojects: [JProject] = []
            for project in projects {
                let jproject = JProject(id: project["id"] as? String ?? "",
                                        key: project["key"] as? String ?? "",
                                        name: project["name"] as? String ?? "",
                                        url: project["self"] as? String ?? "")
                jprojects.append(jproject)
            }
            success(jprojects)
            
        }, failure: { err in
            failure(err)
        })
    }
    
    // GET https://.../rest/api/2/search?jql=project=PROJECT_KEY&fields=*none&maxResults=-1
    // Returns a dictionary that includes an array of issues
    func fetchProjectIssues (projectKey: String, success: @escaping ([JProjectIssue]) -> Void, failure: @escaping (Error) -> Void) {
        
        let path = "rest/api/2/search?jql=project=\(projectKey)&fields=*none&maxResults=-1"
        request?.get(at: path, success: { responseData in
            
            guard let responseJson = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments),
                let response = responseJson as? [String: Any],
                let issues = response["issues"] as? [[String: Any]] else {
                failure(RCHttpError(errorDescription: "Invalid json response"))
                return
            }
            
            var jissues: [JProjectIssue] = []
            for issue in issues {
                let jissue = JProjectIssue(id: issue["id"] as? String ?? "",
                                           key: issue["key"] as? String ?? "",
                                           url: issue["self"] as? String ?? "")
                jissues.append(jissue)
            }
            success(jissues)
            
        }, failure: { err in
            failure(err)
        })
    }
}
