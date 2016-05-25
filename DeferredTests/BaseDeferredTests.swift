//
//  DeferredTests.swift
//  Deferred
//
//  Created by damouse on 5/19/16.
//  Copyright © 2016 I. All rights reserved.
//

import XCTest
import AnyFunction
@testable import Deferred

// Exposes the private property and a utility init not meant to be used directly
class TestableAbstractDeferred: AbstractDeferred {
    init(asSuccess: Bool, handler h: AnyClosureType) {
        super.init()
        
        isSuccess = asSuccess
        handler = h
    }
}

class DeferredTest: XCTestCase {
    // Abstract sets didSucceed appropriately after fire is called
    func testSuccessFlagSet() {
        var d = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.didSucceed != nil && d.didSucceed!)
        
        d = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.didSucceed != nil && !d.didSucceed!)
        
        d = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.didSucceed != nil && d.didSucceed!)
        
        d = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.didSucceed != nil && !d.didSucceed!)
    }
    
    // Abstract sets results appropriately after fire is called
    func testResultsSet() {
        var d = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.results != nil)
        
        d = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.results != nil)
        
        d = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({}))
        d.callback([])
        XCTAssert(d.results != nil)
        
        d = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({}))
        d.errback([])
        XCTAssert(d.results != nil)
    }
 
    
    // Single link
    func testHandlerCallback() {
        let e1 = expectationWithDescription("")
        
        let a = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testHandlerErrback() {
        let e1 = expectationWithDescription("")
        
        let a = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
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
        
        let a = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        let c = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
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
        
        let a = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        let c = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
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
        
        let a = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            XCTFail()
        }))
        
        let c = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
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
        
        let a = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        let b = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            XCTFail()
        }))
        
        let c = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
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
        
        let a = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.callback([])
        
        let b = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e2.fulfill()
        }))

        a.link(b)
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testLazyErrback() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let a = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e1.fulfill()
        }))
        
        a.errback([])
        
        let b = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        a.link(b)
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    
    // When the handler returns a deferred, wait on the result of that deferred, then pass its results to the rest of the chain
    func testNestedCallback() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        let e3 = expectationWithDescription("")
        
        let b = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        let a = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({ () -> AnyObject in
            e1.fulfill()
            return b
        }))
        
        let c = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
            e3.fulfill()
        }))
        
        a.link(c)
        b.callback([])
        a.callback([])
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testNestedErrback() {
        let e1 = expectationWithDescription("Initial Deferred")
        let e2 = expectationWithDescription("Nested deferred")
        let e3 = expectationWithDescription("Error block")
        
        let b = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e2.fulfill()
        }))
        
        let a = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({ () -> AnyObject in
            e1.fulfill()
            return b
        }))
        
        let c = TestableAbstractDeferred(asSuccess: true, handler: Closure.wrap({
             XCTFail()
        }))
        
        let d = TestableAbstractDeferred(asSuccess: false, handler: Closure.wrap({
            e3.fulfill()
        }))
        
        a.link(c)
        a.link(d)
        
        b.errback([])
        a.callback([])
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
}
