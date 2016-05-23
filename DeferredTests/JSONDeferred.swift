//
//  JSONDeferred.swift
//  Deferred
//
//  Created by damouse on 5/23/16.
//  Copyright © 2016 I. All rights reserved.
//

import XCTest
@testable import Deferred

class JSONDeferredTests: XCTestCase {
    // Could potentially expect an empty json object back, as "{}"
    func testEmtpyDeferred() {
        let d = JSONDeferred()
        let e1 = expectationWithDescription("")
        
        d.json() {
            e1.fulfill()
        }
        
        d.callback([:])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testOneArgDeferred() {
        let d = JSONDeferred()
        let e1 = expectationWithDescription("")
        
        d.json("alpha") { (a: String) -> () in
            XCTAssert(a == "one")
            e1.fulfill()
        }
        
        d.callback(["alpha": "one"])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testTwoArgDeferred() {
        let d = JSONDeferred()
        let e1 = expectationWithDescription("")
        
        d.json("alpha", "beta") { (a: String, b: Int) -> () in
            XCTAssert(a == "one")
            XCTAssert(b == 12)
            e1.fulfill()
        }
        
        d.callback(["alpha": "one", "beta": 12])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    
    // Fail on bad key
    func testBadKey() {
        let d = JSONDeferred()
        let e1 = expectationWithDescription("")
        
        d.json("notAlpha", "beta") { (a: String, b: Int) -> () in
            XCTFail()
        }.error { s in
            e1.fulfill()
        }
        
        d.callback(["alpha": "one", "beta": 12])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    // Bad input when resolving the deferred
    func testInputNoArgs() {
        let d = JSONDeferred()
        let e1 = expectationWithDescription("")
        
        d.json() {
            XCTFail()
        }.error { s in
            e1.fulfill()
        }
        
        d.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testInputNoDict() {
        let d = JSONDeferred()
        let e1 = expectationWithDescription("")
        
        d.json() {
            XCTFail()
        }.error { s in
            e1.fulfill()
        }
        
        d.callback([[]])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
}
