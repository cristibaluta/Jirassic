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
		
		XCTAssertFalse(predictor.decimalValueOf("", newDigit: "2") == 1, "")
		XCTAssert(predictor.decimalValueOf("", newDigit: "2") == 2, "")
		XCTAssert(predictor.decimalValueOf("", newDigit: "") == 0, "")
		XCTAssert(predictor.decimalValueOf("1", newDigit: "2") == 12, "")
		XCTAssert(predictor.decimalValueOf("59", newDigit: "3") == 593, "")
    }
	
	func testDateFromString() {
		
		var date = predictor.dateFromStringHHmm("12:25")
		XCTAssert(date.HHmm() == "12:25", "")
		date = predictor.dateFromStringHHmm("12")
		XCTAssert(date.HHmm() == "12:00", "")
		date = predictor.dateFromStringHHmm("")
		XCTAssert(date.HHmm() == "00:00", "")
	}
	
	func testHourPredictor() {
		
		XCTAssert(predictor.timeByAdding("0", to: "") == "0", "")
		XCTAssert(predictor.timeByAdding("1", to: "") == "1", "")
		XCTAssert(predictor.timeByAdding("2", to: "") == "2", "")
		XCTAssert(predictor.timeByAdding("3", to: "") == "03:", "Adding first h digit greater than 3 can mean only 03: in the morning")
		XCTAssert(predictor.timeByAdding("", to: "03:") == "0", "No char means deleting. Deleting last h digit deletes the : as well")
		XCTAssert(predictor.timeByAdding("", to: "0") == "", "")
		XCTAssert(predictor.timeByAdding("2", to: "0") == "02:", "")
		XCTAssert(predictor.timeByAdding("3", to: "0") == "03:", "")
		XCTAssert(predictor.timeByAdding("0", to: "1") == "10:", "")
		XCTAssert(predictor.timeByAdding("9", to: "2") == "00:", "Adding more than 24h sets it to 00")
	}
	
	// Minutes are predicted to the first greater quarter or 10th
	func testMinutesPredictor() {
		
		XCTAssert(predictor.timeByAdding("0", to: "05:") == "05:00", "")
		XCTAssert(predictor.timeByAdding("1", to: "05:") == "05:15", "")
		XCTAssert(predictor.timeByAdding("2", to: "05:") == "05:20", "")
		XCTAssert(predictor.timeByAdding("3", to: "05:") == "05:30", "")
		XCTAssert(predictor.timeByAdding("4", to: "05:") == "05:45", "")
		XCTAssert(predictor.timeByAdding("5", to: "05:") == "05:50", "")
		XCTAssert(predictor.timeByAdding("6", to: "05:") == "05:06", "If minutes begins with 6 or greater, use it as final value")
		XCTAssert(predictor.timeByAdding("9", to: "05:") == "05:09", "")
		XCTAssert(predictor.timeByAdding("9", to: "05:1") == "05:19", "")
		XCTAssert(predictor.timeByAdding("9", to: "05:18") == "05:19", "")
		XCTAssert(predictor.timeByAdding("6", to: "05:09") == "05:06", "When the time is complete but you still add digits, replace the last digit with new value")
		XCTAssert(predictor.timeByAdding("", to: "05:09") == "05:0", "")
		XCTAssert(predictor.timeByAdding("", to: "05:0") == "05:", "")
	}
}
