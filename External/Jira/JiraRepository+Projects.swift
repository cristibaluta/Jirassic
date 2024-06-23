//
//  JiraRepository+Projects.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCHttp

extension JiraRepository {
    
    /// GET https://.../rest/api/2/project
    /// Returns an array of projects
    /* Most common error is captcha
    HTTP/1.1 403 Forbidden
    Date: Mon, 05 Apr 2021 13:03:25 GMT
    Server: Apache-Coyote/1.1
    X-AREQUESTID: 963x1873889x1
    X-ASEN: SEN-2826527
    X-Seraph-LoginReason: AUTHENTICATION_DENIED
    WWW-Authenticate: OAuth realm="https"
    X-ASESSIONID: 6pk78p
    X-Content-Type-Options: nosniff
    X-Authentication-Denied-Reason: CAPTCHA_CHALLENGE; login-url=https://jira...../login.jsp
    Content-Type: text/html;charset=UTF-8
    Set-Cookie: JSESSIONID=CF54E3A2E1CAA26E3C36CBA7118A541B; Path=/; HttpOnly
    Transfer-Encoding: chunked*/
    func fetchProjects (success: @escaping ([JProject]) -> Void, failure: @escaping (Error) -> Void) {
        
        let path = "rest/api/2/project"
        request?.get(at: path, success: { httpResponse, responseData in
            
            guard httpResponse.statusCode != 403 else {
                failure(RCHttpError(errorDescription: "Authentication failed. Please verify via browser, possible cause is expired password which is causing Jira to ask for captcha."))
                return
            }
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
        request?.get(at: path, success: { httpResponse, responseData in
            
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
