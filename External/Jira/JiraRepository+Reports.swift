//
//  Jira+Reports.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/07/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension JiraRepository {
    
//    // https://.../rest/tempo-timesheets/3/worklogs/?dateFrom=2017-06-01&dateTo=2017-06-30&username=cristianbal
//    func fetchReports (ofDay day: Date, completion: (() -> Void)?) {
//        
//        
//    }
//    
//    func deleteReports (ofDay day: Date, completion: ((Bool) -> Void)?) {
//        
//    }
    
    // POST https://.../rest/tempo-timesheets/3/worklogs/
    func postReports (_ reports: [Report], in project: JProject, to issue: JProjectIssue, date: Date, completion: (() -> Void)?) {
        // Join reports into a single string
        
        // Send to jira
        var comment = ""
        var duration = 0.0
        for report in reports {
            comment += report.taskNumber + " - " + report.title + "\n" + report.notes + "\n\n"
            duration += report.duration
        }
        let dateStarted = date.YYYYMMddT00()//"2017-07-03T00:00:00.000+0000"
        let path = "rest/tempo-timesheets/3/worklogs"
        let parameters: [String: Any] = [
            "issue": [
                "key": issue.key,
                "projectId": project.id
            ],
            "author": [
                "name": self.user
            ],
            "comment": comment,
            "dateStarted": dateStarted,
            "timeSpentSeconds": duration
        ]
        request?.post(at: path, parameters: parameters, success: { (response) in
            
            if let projects = response as? [[String: Any]] {
                
                completion?()
            } else {
                completion?()
            }
            
        }, failure: { (err) in
            completion?()
        })
    }
}

//extension JiraRepository {
//    
//    fileprivate func reportsToJReports(_ reports: [Report]) -> [JReport] {
//        return reports.map({ reportToJReport($0) })
//    }
//    
//    fileprivate func reportToJReport(_ report: Report) -> JReport {
//        
//        let author = JAuthor(name: "self.user")
//        let issue = JIssue(key: "", projectId: 0)
//        let jreport = JReport(comment: report.notes, 
//                              dateStarted: "", 
//                              timeSpentSeconds: Int(report.duration), 
//                              author: author, 
//                              issue: issue, 
//                              workAttributeValues: [])
//        
//        return jreport
//    }
//    
//    fileprivate func serializedJReports (_ jreports: [JReport]) -> [String: Any] {
//        
//        return [String: Any]()
//    }
//}
