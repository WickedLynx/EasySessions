//
//  EasySessionsTests.swift
//  EasySessionsTests
//
//  Created by Harshad on 20/08/15.
//  Copyright (c) 2015 Laughing Buddha Software. All rights reserved.
//

import UIKit
import XCTest
import EasySessions

class EasySessionsTests: XCTestCase {
    let sessionManager = SessionManager(parser: nil)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sessionManager.loggingEnabled = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDataLoading() {
        let baseURL = NSURL(string: "http://www.apple.com/")!
        let path = "support"
        guard let url = NSURL.URLWithPath(path: path, query: nil, relativeToURL: baseURL) else {
            XCTFail("Failed to build URL")
            return
        }
        do {
            let request = try NSMutableURLRequest.jsonPOSTRequest(URL: url, jsonObject: ["" : ""])
            let expectation1 = expectationWithDescription("Completion Handler1 Called")
            sessionManager.ephemeralDataDownloadTaskWithRequest(request, completion: { (data, response, error) -> Void in
                expectation1.fulfill()
                XCTAssertGreaterThan(data?.length ?? 0, 0, "Data did not load for \(url)")
                XCTAssertNotNil(response, "Did not receive response for \(url)")
                XCTAssertNil(error, "Encountered error for \(url)\nError is: \(error)")
            })
            waitForExpectationsWithTimeout(60, handler: { (error) -> Void in
                print("Timed out:\n\(error)")
            })
        } catch {
            XCTFail("Failed to create a request. Error: \(error)")
        }
    }

}
