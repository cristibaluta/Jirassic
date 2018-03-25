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
    func postWorklog (_ worklog: String,
                      duration: Double,
                      in project: JProject,
                      to issue: JProjectIssue,
                      date: Date,
                      completion: ((_ success: Bool) -> Void)?) {
        // Join reports into a single string
        
        // Send to jira

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
            "comment": worklog,
            "dateStarted": dateStarted,
            "timeSpentSeconds": duration
        ]
        request?.post(at: path, parameters: parameters, success: { (response) in
            
            if let _ = response as? [[String: Any]] {
                completion?(true)
            } else {
                completion?(false)
            }
            
        }, failure: { (err) in
            completion?(false)
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
