//
//  DeferredTests.swift
//  DeferredTests
//
//  Created by damouse on 5/4/16.
//  Copyright © 2016 I. All rights reserved.
//
//  Simple primitive assigment on a base class

import XCTest
@testable import Deferred

// Success propogation and and handling
class CallbackTest: XCTestCase {
    func testDefault() {
        let e1 = expectationWithDescription("")
        let d = Deferred<Void>()
        
        d.then {
            e1.fulfill()
        }
        
        d.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }

    func testChain() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let d = Deferred<Void>()

        d.then {
            e1.fulfill()
        }.then {
            e2.fulfill()
        }
        
        d.callback([])
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    // immediately fire callback handler if the chain has already been fired
    func testLazy() {
        let e1 = expectationWithDescription("")
        let d = Deferred<Void>()
        
        d.callback([])
        
        d.then {
            e1.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    // Waiting for an internal deferred to resolve
    func testNested() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        let e3 = expectationWithDescription("")
        
        let d = Deferred<Void>()
        let f = Deferred<Void>()
        
        f.then {
            e1.fulfill()
        }
        
        d.then { () -> Deferred<Void> in
            e2.fulfill()
            return f
        }.then {
            e3.fulfill()
        }
        
        d.callback([])
        f.callback([])
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    // Nested callbacks with generic constrains
    func testParam() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        
        let d = Deferred<Void>()
        let e = Deferred<String>()
        
        d.then { () -> Deferred<String> in
            e1.fulfill()
            return e
        }.then { s in
            XCTAssert(s == "Done")
            e2.fulfill()
        }
        
        d.callback([])
        e.callback(["Done"])
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
}

// Error propogation and handling
class ErrbackTest: XCTestCase {
    func testDefault() {
        let e1 = expectationWithDescription("")
        let d = Deferred<Void>()

        d.error { e in
            XCTAssert(e == "Fail")
            e1.fulfill()
        }
        
        d.errback(["Fail"])

        waitForExpectationsWithTimeout(1.0, handler:nil)
    }

    func testChain() {
        let e1 = expectationWithDescription("First errback")
        let e2 = expectationWithDescription("Second errback")
        let d = Deferred<Void>()
        
        d.error { e in
            XCTAssert(e == "Fail")
            e1.fulfill()
        }.error { e in
            XCTAssert(e == "Fail")
            e2.fulfill()
        }
        
        d.errback(["Fail"])

        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
    
    func testLazy() {
        let e1 = expectationWithDescription("")
        let d = Deferred<Void>()
        
        d.errback(["Fail"])
        
        d.error { e in
            XCTAssert(e == "Fail")
            e1.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }

    func testNested() {
        let e1 = expectationWithDescription("")
        let e2 = expectationWithDescription("")
        let e3 = expectationWithDescription("")
        
        let d = Deferred<Void>()
        let f = Deferred<Void>()
        
        f.error { s in
            e1.fulfill()
        }
        
        d.then { () -> Deferred<Void> in
            e2.fulfill()
            return f
        }.then {
            XCTFail()
        }.error { s in
            e3.fulfill()
        }
        
        d.callback([])
        f.errback(["Reason"])
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
}


/*
// A Mix of the above two. Given a deferred that returns value in some known
// type, returning that deferred should chain the following then as a callback of the appropriate type
_ = {
    var d = Deferred<Void>()
    let f = Deferred<String>()
    
    d.chain { () -> Deferred<String> in
        print(1)
        return f
    }.then { s in
        print(s)
        print(2)
    }.then {
        print(3) // I dont take any args, since the block above me didnt reutn a deferred
    }.error { err in
        print("Error: \(err)")
    }
    
    d.callback([])
    // f.callback(["Hello"])
    f.errback(["early termination"])
    }()


// Chaining deferreds twice
_ = {
    var d = Deferred<Void>()
    let f = Deferred<String>()
    let c = Deferred<Bool>()
    
    d.chain { () -> Deferred<String> in
        print(1)
        return f
    }.chain { str -> Deferred<Bool> in
        print(2, str)
        return c
    }.then { bool in
        print(3, bool)
    }.error { err in
        print("Error: \(err)")
    }
    
    // Comment out lines below and make sure the prints do or dont show up in order
    d.callback([])
    f.callback(["Hello"])
    c.callback([true])
    
    // f.errback(["early termination"])
    }()
*/