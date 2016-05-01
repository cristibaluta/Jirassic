//
//  Issues.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/09/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadIssuesInteractor {

	class func all() -> [String] {
		return ["BOSCH-33 Refactoring", "BOSCH-34 UX"]
	}
	
	class func match (searchString: String) -> [String] {
		return all()
//			.filter({ (_: Issues.Generator.Element) -> Bool in
//			return true
//		})
	}
	
	class func mostUsed() -> [String] {
		return all()
	}
	
	class func lastUsed() -> String {
		return all().first!
	}
}
