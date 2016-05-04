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

class CallbackTest: XCTestCase {
    func testDefaultCallback() {
        let expectation = expectationWithDescription("Default callbacks should succeed")
        
        let d = Deferred<Void>()
        
        d.then {
            XCTAssert(true)
            expectation.fulfill()
        }
        
        d.callback([])
        
        waitForExpectationsWithTimeout(1.0, handler:nil)
    }
}

/*
///
// Exmaples and inline tests follow
///

// Default, no args errback and callback
_ = {
    let d = Deferred<Void>()
    
    d.then {
        print("Default Then")
        let a = 1
    }
    
    d.callback([])
    
    d.error { r in
        print("DefaultError")
        let b = 2
    }
    
    d.errback(["Asdf"])
    }()


// Default chaining
_ = {
    let d = Deferred<Void>()
    
    d.then {
        let a = 1
        }.then {
            let b = 2
    }
    
    d.callback([])
    
    d.error { e in
        let a = 3
        }.error { e in
            let b = 4
    }
    
    d.errback([""])
    }()


// Lazy callbacks- immediately fire callback handler if the chain has already been called back
_ = {
    var d = Deferred<Void>()
    d.callback([])
    
    d.then {
        let a = 1
        }.then {
            let b = 2
    }
    
    d.errback([""])
    
    d.error { e in
        let a = 1
        }.error { e in
            let b = 2
    }
    }()


// Waiting for an internal deferred to resolve
_ = {
    var d = Deferred<Void>()
    let f = Deferred<Void>()
    
    // This is pretty close, but not quite there
    f.then { s in
        print(12)
    }
    
    d.chain {
        print(11)
        return f
        }.then {
            print(13)
    }
    
    d.callback([])
    f.callback(["Hello"])
    }()


// Param constraints
_ = {
    var d = Deferred<()>()
    var e = Deferred<String>()
    
    d.chain { () -> Deferred<String> in
        let a = 1
        return e
        }.then { s in
            print("Have", s)
            let a = 2
    }
    
    d.callback([1])
    e.callback(["Done!"])
    }()


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