//
//  DeferredTests.swift
//  Deferred
//
//  Created by damouse on 5/19/16.
//  Copyright © 2016 I. All rights reserved.
//

import XCTest
@testable import Deferred

class DeferredTest: XCTestCase {
    // Abstract sets didSucceed appropriately after fire is called
    func testSuccessFlagSet() {
        var d = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.didSucceed != nil && d.didSucceed!)
        
        d = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.didSucceed != nil && !d.didSucceed!)
        
        d = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.didSucceed != nil && d.didSucceed!)
        
        d = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.didSucceed != nil && !d.didSucceed!)
    }
    
    // Abstract sets results appropriately after fire is called
    func testResultsSet() {
        var d = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.results != nil)
        
        d = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.results != nil)
        
        d = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.results != nil)
        
        d = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.results != nil)
    }
 
    
    // Single link
    func testHandlerCallback() {
        let e1 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testHandlerErrback() {
        let e1 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.errback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    
    // Three link chain
    func testCallbackChain() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        let e3 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        let c = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e3.fulfill()
        }))
        
        b.link(c)
        a.link(b)
        
        a.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testErrbackChain() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        let e3 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        let c = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e3.fulfill()
        }))
        
        b.link(c)
        a.link(b)
        
        a.errback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    
    // Three link heterogenous chain (success-error-success or vis versa)
    func testCallbackMixed() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            XCTFail()
        }))
        
        let c = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        b.link(c)
        a.link(b)
        
        a.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }

    func testErrbackMixed() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            XCTFail()
        }))
        
        let c = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        b.link(c)
        a.link(b)
        
        a.errback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)

    }
    
    
    // Lazy link firing. When a deferred has already been fired and then has a link added, immediately fire the link
    func testLazyCallback() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.callback([])
        
        let b = AAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e2.fulfill()
        }))

        a.link(b)
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testLazyErrback() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let a = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.errback([])
        
        let b = AAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        a.link(b)
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
}
