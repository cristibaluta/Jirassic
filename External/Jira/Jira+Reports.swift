//
//  Jira+Reports.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/07/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension JiraRepository {
    
    func fetchReports (ofDay day: Date, completion: (() -> Void)?) {
        // https://jira.fortech.ro/rest/tempo-timesheets/3/worklogs/?dateFrom=2017-06-01&dateTo=2017-06-30&username=cristianbal
    }
    
    func deleteReports (ofDay day: Date, completion: ((Bool) -> Void)?) {
        
    }
    
    func postReports (_ reports: [Report], completion: (() -> Void)?) {
        // https://jira.fortech.ro/rest/tempo-timesheets/3/worklogs/
    }
    
}

extension JiraRepository {
    
    fileprivate func reportsToJReports(_ reports: [Report]) -> [JReport] {
        return reports.map({ reportToJReport($0) })
    }
    
    fileprivate func reportToJReport(_ report: Report) -> JReport {
        
        let author = JAuthor(name: self.user)
        let issue = JIssue(key: "", projectId: 0)
        let jreport = JReport(comment: report.notes, 
                              dateStarted: "", 
                              timeSpentSeconds: Int(report.duration), 
                              author: author, 
                              issue: issue, 
                              workAttributeValues: [])
        
        return jreport
    }
    
    fileprivate func serializedJReports (_ jreports: [JReport]) -> [String: Any] {
        
        return [String: Any]()
    }
}
