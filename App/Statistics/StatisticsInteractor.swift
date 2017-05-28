//
//  StatisticsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class StatisticsInteractor {
    
    func workedTime (fromTasks tasks: [Task], targetHoursInDay: Double?) -> Double {
        
        guard tasks.count > 1 else {
            return 0.0
        }
        
        let workedTime = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
//        let requiredHours = targetHoursInDay != nil ? targetHoursInDay! : workedTime
//        let missingTime = requiredHours - workedTime
        
        return workedTime
    }
    
    func workedTime (fromReports reports: [Report]) -> Double {
        
        guard reports.count > 0 else {
            return 0.0
        }
        
        var workedTime = 0.0
        for report in reports {
            workedTime += report.duration
        }
        
        return workedTime
    }
}
