//
//  PredictiveTimeTypingTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/09/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class PredictiveTimeTypingTests: XCTestCase {
	
	let predictor = PredictiveTimeTyping()
	
    func testStringToDecimal() {
		
		XCTAssertFalse(predictor.decimalValueOf("", newText: "2") == 1, "")
		XCTAssert(predictor.decimalValueOf("", newText: "2") == 2, "")
		XCTAssert(predictor.decimalValueOf("2", newText: "2") == 22, "")
    }
	
	func testDateFromString() {
		
		var date = predictor.dateFromStringHHmm("12:25")
		XCTAssert(date.HHmm() == "12:25", "")
		date = predictor.dateFromStringHHmm("12")
		XCTAssert(date.HHmm() == "12:00", "")
		date = predictor.dateFromStringHHmm("")
		XCTAssert(date.HHmm() == "00:00", "")
	}
	
	func testPredictor() {
		
		
	}
}
