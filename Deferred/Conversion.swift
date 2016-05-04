//
//  Conversino.swift
//  Deferred
//
//  Created by damouse on 5/4/16.
//  Copyright © 2016 I. All rights reserved.
//

import Foundation

protocol Convertible {
    // Convert the given argument to this type
    static func to<T: AnyObject>(from: T) -> Self
    
    // Get a serializable value from this type
    func from() -> AnyObject
}

// By creating a base "implementation" of the protocol we can inject
// CN into a lot of stuff without having to implement each individually
protocol BaseConvertible: Convertible {}

extension BaseConvertible {
    static func to<T: AnyObject>(from: T) -> Self { return from as! Self }
    func from() -> AnyObject { return self as! AnyObject }
}

typealias CN = Convertible

extension String : BaseConvertible { }
extension Int : BaseConvertible { }
extension Bool : BaseConvertible { }
