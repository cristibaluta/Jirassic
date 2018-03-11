//
//  GitBranchParser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class GitBranchParser {
    
    private var raw: String
    
    init (raw: String) {
        self.raw = raw
    }
    
    func firstBranchName() -> String {
        return branches().first ?? ""
    }
    
    func branches() -> [String] {
        
        var arr = [String]()
        
        let r = raw.replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        let results = r.split(separator: "\n").map { String($0) }
        
        for result in results {
            if result.count > 0 {
                arr.append(result)
            }
        }
        
        return arr
    }
}
