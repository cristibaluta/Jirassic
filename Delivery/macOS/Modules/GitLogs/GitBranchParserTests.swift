//
//  GitBranchParserTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 20/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class GitBranchParserTests: XCTestCase {

    let raw = "   branch1\r" +
        "branch2\n" +
        "* branch3\r\n" +
        " \r" +
        "  branch4"
    
    func testBranches() {
        
        let parser = GitBranchParser(raw: raw)
        let branches = parser.branches()
        
        
        XCTAssert(branches.count == 4)
        XCTAssert(branches[0] == "branch1")
        XCTAssert(branches[1] == "branch2")
        XCTAssert(branches[2] == "branch3")
        XCTAssert(branches[3] == "branch4")
    }
    
    func testBranchName() {
        
        let parser = GitBranchParser(raw: raw)
        let branchName = parser.branchName()
        XCTAssert(branchName == "branch1")
    }
}
