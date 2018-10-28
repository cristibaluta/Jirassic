//
//  StringIdGenerator.swift
//  Jirassic
//
//  Created by Cristian Baluta on 03/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

extension String {
    
    static func generateId (_ length: Int = 20) -> String {
        
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(chars.count))
            randomString += "\(chars[chars.index(chars.startIndex, offsetBy: Int(randomValue))])"
        }
        
        return randomString
    }
}
