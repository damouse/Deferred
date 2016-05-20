//
//  ClosureTests.swift
//  Deferred
//
//  Created by damouse on 5/18/16.
//  Copyright © 2016 I. All rights reserved.
//

import XCTest
@testable import Deferred


class ClosureSuccessTests: XCTestCase {
    func testReturn() {
        let c = Closure.wrap { (a: String) in a }
        let ret = try! c.call(["Test"])
        
        XCTAssert(ret.count == 1)
        XCTAssert(ret[0] as! String == "Test")
    }
    
    // More than one param
    func testMultipleParams() {
        let c = Closure.wrap { (a: String, b: Int) in }
        let ret = try! c.call(["Test", 1])
    }
}


class ClosureFailureTests: XCTestCase {
    // Too many arguments
    func testBadNumParamsVoid() {
        let c = Closure.wrap({ })
        
        do {
            try c.call([1])
            XCTFail()
        } catch {}
    }
    
    // too few arguments
    func testBadNumParamsOne() {
        let c = Closure.wrap({ (a: Int) in })
        
        do {
            try c.call([])
            XCTFail()
        } catch {}
    }
    
    // This is already tested in Conversion tests, so more of a sanity check that the throws work correctly
    func testBadType() {
        let c = Closure.wrap({ (a: Int) in })
        
        do {
            try c.call(["Not an Int"])
            XCTFail()
        } catch {}
    }
}
