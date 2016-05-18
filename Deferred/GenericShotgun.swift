//
//  GenericShotgun.swift
//  Deferred
//
//  Created by damouse on 5/18/16.
//  Copyright © 2016 I. All rights reserved.
//

import Foundation


// A closure wrapper factory that automatically wraps the handler in an executor.
// Does not enforce constraints on allowed types. Strangely this method errs on BaseClosure
public class Closure {
    
    // This is a special case, since it covers cases where either or both A and B can be Void.
    public static func wrap<A, R>(fn: A -> R) -> BaseClosure<A, R> {
        return BaseClosure(fn: fn).setCurry { a in
            let result: R?
            
            if A.self == Void.self {
                result = fn(() as! A)
            } else {
                if a.count != 1 { throw ConversionError.BadNumberOfArguments(expected: 1, actual: a.count) }
                result = fn(try convert(a[0], to: A.self))
            }
            
            if R.self == Void.self {
                return []
            } else {
                return [result! as! AnyObject]
            }
        }
    }
    
    public static func wrap<A, B, R>(fn: (A, B) -> R) -> BaseClosure<(A, B), R> {
        return BaseClosure(fn: fn).setCurry { a in
            if a.count != 2 { throw ConversionError.BadNumberOfArguments(expected: 2, actual: a.count) }
            let ret = fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self))
            return [ret as! AnyObject]
        }
    }
    
    public static func wrap<A, B, C, R>(fn: (A, B, C) -> R) -> BaseClosure<(A, B, C), R> {
        return BaseClosure(fn: fn).setCurry { a in
            if a.count != 3 { throw ConversionError.BadNumberOfArguments(expected: 3, actual: a.count) }
            let ret = fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self), try convert(a[2], to: C.self))
            return [ret as! AnyObject]
        }
    }
    
    // Start Generic Shotgun
    // End Generic Shotgun
}

