//
//  AnyFunction.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//  Generic wrappers that allow "AnyFunction" to be accepted and constrained by type and number of parameters
//  AnyFunction functionality seems to have been lost when this code was linked up with Convertible code. If we 
//  still want to support that we have to change a few things up

import Foundation


protocol AnyClosureType {
    func call(args: [AnyObject]) throws -> [AnyObject]
}

protocol ClosureType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    var handler: ParameterTypes -> ReturnTypes { get }
}

// Concrete and invokable. Doesn't care about types
class BaseClosure<A, B>: AnyClosureType, ClosureType {
    let handler: A -> B
    var curried: ([AnyObject] throws -> [AnyObject])!
    
    // For some reason the generic constraints aren't forwarded correctly when
    // the curried function is passed along, so it gets its own method below
    // You must call setCurry immediately after init!
    init(fn: A -> B) {
        handler = fn
    }
    
    func call(args: [AnyObject]) throws -> [AnyObject] {
        return try curried(args)
    }
    
    func setCurry(fn: [AnyObject] throws -> [AnyObject]) -> Self {
        curried = fn
        return self
    }
}


// These are factory functions. I'm not a fan of how they're set up right now, but its a work in progress.

// This is a special case, since it covers cases where either or both A and B can be Void.
func constrain<A, B>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn).setCurry { a in
        let result: B?
        
        if A.self == Void.self {
            result = fn(() as! A)
        } else {
            result = fn(try convert(a[0], to: A.self))
        }
        
        if B.self == Void.self {
            return []
        } else {
            return [result! as! AnyObject]
        }
    }
}

func constrain<A, B, C>(fn: (A, B) -> C) -> BaseClosure<(A, B), C> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self)) as! AnyObject]}
}





