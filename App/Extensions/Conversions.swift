//
//  Zeta.swift
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
    
    var hoursToSec: Double {
        return self * 60 * 60
    }
}
