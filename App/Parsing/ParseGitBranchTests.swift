//
//  ParseGitBranchTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 28/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class ParseGitBranchTests: XCTestCase {

    func test() {
        
        var parser = ParseGitBranch(branchName: "AA-1234-branch-name")
        XCTAssert(parser.taskNumber() == "AA-1234")
        XCTAssert(parser.taskTitle() == "branch name")
        
        parser = ParseGitBranch(branchName: "AA-1234__branch_name")
        XCTAssert(parser.taskNumber() == "AA-1234")
        XCTAssert(parser.taskTitle() == "branch name")
        
        parser = ParseGitBranch(branchName: "some_branch_name")
        XCTAssertNil(parser.taskNumber())
        XCTAssert(parser.taskTitle() == "some branch name")
    }
    
    func testMergeCommitMessage() {
        
        let parser = ParseGitBranch(branchName: "Merge pull request #619 in MYAPP/proj from AA-1234_some_branch_name to master;")
        XCTAssert(parser.taskNumber() == "AA-1234")
        XCTAssert(parser.taskTitle() == "some branch name")
    }
    
    func testBranchesGivenByGitLog() {
        
        var parser = ParseGitBranch(branchName: "origin/some_branch_name, some_branch_name")
        XCTAssertNil(parser.taskNumber())
        XCTAssert(parser.taskTitle() == "some branch name")
        
        parser = ParseGitBranch(branchName: "origin/AA-1234_some_branch_name")
        XCTAssert(parser.taskNumber() == "AA-1234")
        XCTAssert(parser.taskTitle() == "some branch name")
    }
}
