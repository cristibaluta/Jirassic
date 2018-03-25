//
//  GitCommitsParserTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 17/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class GitCommitsParserTests: XCTestCase {

    func testParser() {
        
        let raw = "0;1517923183;me@email.com;AAA-3007 Refactor;\n" +
        "0;1517922963;you@email.com;AAA-3007 Refactor;\r" +
        "0;1517922230;me@email.com;AAA-3007 Refactor;(AAA-3007_Branchname)\r\n" +
        "0;1517922230;me@email.com;AAA-3007 Refactor;(AAA-3007_Branchname)\n\r" +
        "0;1517922230;me@email.com;AAA-3007 Refactor;(AAA-3007_Branchname)"
        
        let parser = GitCommitsParser(raw: raw)
        let commits = parser.toGitCommits()
        
        XCTAssert(commits.count == 5)
        
        let commit1 = commits[0]
        XCTAssert(commit1.authorEmail == "me@email.com")
        XCTAssert(commit1.message == "AAA-3007 Refactor")
        XCTAssertNil(commit1.branchName)
    }
}
