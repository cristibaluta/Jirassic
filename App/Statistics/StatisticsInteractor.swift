//
//  StatisticsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class StatisticsInteractor {
    
    func duration (of tasks: [Task]) -> Double {
        
        guard tasks.count > 1 else {
            return 0.0
        }
        let time = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
        return time
    }
    
    func duration (of reports: [Report]) -> Double {
        
        var time = 0.0
        for report in reports {
            time += report.duration
        }
        return time
    }
}
