//
//  RCPreferencesTests.swift
//
//  Created by Cristian Baluta on 12/03/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import XCTest
@testable import ...

class RCPreferencesTests: XCTestCase {

    enum UserPreferences: String, RCPreferencesProtocol {
        case option1 = "option1"
        case option2 = "option2"
        case option3 = "option3"
        case option4 = "option4"
        func defaultValue() -> Any {
            switch self {
            case .option1: return false
            case .option2: return "some string"
            case .option3: return 4
            case .option4: return Date()
            }
        }
    }
    
    let settings = RCPreferences<UserPreferences>()
    
    override func setUp() {
        super.setUp()
        settings.reset(.option1)
        settings.reset(.option2)
        settings.reset(.option3)
        settings.reset(.option4)
    }
    
    func testDefaultValues() {
        
        XCTAssertFalse(settings.bool(.option1))
        XCTAssert(settings.string(.option2) == "some string")
        XCTAssert(settings.int(.option3) == 4)
        XCTAssert(settings.date(.option4).isSameDayAs(Date()))
    }
    
    func testWritingValues() {

        settings.set(true, forKey: .option1)
        settings.set("some other string", forKey: .option2)
        settings.set(5, forKey: .option3)
        XCTAssertTrue(settings.bool(.option1))
        XCTAssert(settings.string(.option2) == "some other string")
        XCTAssert(settings.int(.option3) == 5)
        
        settings.reset(.option1)
        settings.reset(.option2)
        settings.reset(.option3)
        settings.reset(.option4)
        XCTAssertFalse(settings.bool(.option1))
        XCTAssert(settings.string(.option2) == "some string")
        XCTAssert(settings.int(.option3) == 4)
    }
}
