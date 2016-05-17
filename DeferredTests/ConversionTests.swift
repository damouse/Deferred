//
//  ConversionTests.swift
//  Deferred
//
//  Created by damouse on 5/17/16.
//  Copyright © 2016 I. All rights reserved.
//
//  These tests cover converstion TO swift types
//  Note that "Primitives" refers to JSON types that arent collections

import XCTest
@testable import Deferred

// Primitives
class StringConversion: XCTestCase {
    func testSameType() {
        let a: String = "asdf"
        let b = try! convert(a, to: String.self)
        XCTAssert(a == b)
    }
    
    func testFromFoundation() {
        let a: NSString = "asdf"
        let b = try! convert(a, to: String.self)
        XCTAssert(a == b)
    }
}

class IntConversion: XCTestCase {
    func testSameType() {
        let a: Int = 1
        let b = try! convert(a, to: Int.self)
        XCTAssert(a == b)
    }
    
    func testFromFoundation() {
        let a: NSNumber = 1
        let b = try! convert(a, to: Int.self)
        XCTAssert(a == b)
    }
}

class FloatConversion: XCTestCase {
    func testSameType() {
        let a: Float = 123.456
        let b = try! convert(a, to: Float.self)
        XCTAssert(a == b)
    }
    
    func testFromFoundation() {
        let a: NSNumber = 123.456
        let b = try! convert(a, to: Float.self)
        XCTAssert(b == 123.456)
    }
}

class DoubleConversion: XCTestCase {
    func testSameType() {
        let a: Double = 123.456
        let b = try! convert(a, to: Double.self)
        XCTAssert(a == b)
    }
    
    func testFromFoundation() {
        let a: NSNumber = 123.456
        let b = try! convert(a, to: Double.self)
        XCTAssert(b == 123.456)
    }
}

class BoolConversion: XCTestCase {
    func testSameType() {
        let a: Bool = true
        let b = try! convert(a, to: Bool.self)
        XCTAssert(a == b)
    }
    
    func testFromFoundation() {
        let a: ObjCBool = true
        let b = try! convert(a, to: Bool.self)
        XCTAssert(b == true)
    }
}


// Collections
class ArrayConversion: XCTestCase {
    func testSameType() {
        let a: [String] = ["asdf", "qwer"]
        let b = try! convert(a, to: [String].self)
        XCTAssert(a == b)
    }
    
    // NSArray with Convertible elements
    func testFoundationArray() {
        let a: NSArray = NSArray(objects: "asdf", "qwer")
        let b = try! convert(a, to: [String].self)
        XCTAssert(a == b)
    }
    
    // Swift array with Foundation elements
    func testFoundationElements() {
        let a: [NSString] = [NSString(string: "asdf"), NSString(string: "qwer")]
        let b = try! convert(a, to: [String].self)
        XCTAssert(a == b)
    }
}















