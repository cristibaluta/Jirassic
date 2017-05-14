//
//  StringArray.swift
//  Jirassic
//
//  Created by Cristian Baluta on 14/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension String {
    
    func toArray() -> [String] {
        return self.components(separatedBy: ",")
    }
}

extension Array where Iterator.Element == String {
    
    func toString() -> String {
        return self.joined(separator: ",")
    }
}
