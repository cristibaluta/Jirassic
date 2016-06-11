//
//  IssuesInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/09/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class IssuesInteractor: RepositoryInteractor {

    func allIssues (completion: [String] -> Void) {
        
        data.queryIssues ({issues in
            completion(issues)
        }, errorBlock: { error in
        
        })
	}
	
	func search (searchString: String, completion: [String] -> Void) {
//		return allIssues()
//			.filter({ (_: Issues.Generator.Element) -> Bool in
//			return true
//		})
	}
	
	func mostUsed (completion: String -> Void) {
		completion("")
	}
	
	func lastUsed (completion: String -> Void) {
		completion("")
	}
}
