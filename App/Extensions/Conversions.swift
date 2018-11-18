//
//  Conversions.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/11/2016.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

extension Double {
    
    var minToSec: Double {
        return self * 60
    }

    var monthsToSec: Double {
        return self * 30 * 24.hoursToSec
    }

    var hoursToSec: Double {
        return self * 3600
    }
    
    var secToHours: Double {
        return self / 3600
    }
    
    /// Transforms a number of seconds into 'hours minutes'. The hours can be over 24
    var secToHoursAndMin: String {
        let h = floor(self / 3600)
        let secondsRemaining = self - h * 3600
        let m = secondsRemaining / 60
        let hours = Int(h)
        let minutes = Int(m)
        return "\(hours)h \(minutes)m"
    }
    
    /// One hour equals to 1 percent
    var secToPercent: Double {
        return Double(Darwin.round((self / 3600) * 100) / 100)
    }
}
