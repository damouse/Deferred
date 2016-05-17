//
//  AnyFunction.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//  Generic wrappers that allow "AnyFunction" to be accepted and constrained by type and number of parameters

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



// These are factory functions
// Generates constrained concrete closures. Some of these methods have different names
// instead of overloads to cases where non-generic overrides get called instead of the generic ones
func constrainVoidVoid(fn: () -> ())  -> BaseClosure<Void, Void> {
    return BaseClosure(fn: fn).setCurry { a in fn(); return [] }
}

func constrainOneVoid<A>(fn: (A) -> ()) -> BaseClosure<A, Void> {
    return BaseClosure(fn: fn).setCurry { a in
        if A.self == Void.self {
            fn(() as! A)
        } else {
            fn(try convert(a[0], to: A.self))
        }
        
        return []
    }
}

func constrainVoidOne<A>(fn: () -> A) -> BaseClosure<Void, A> {
    return BaseClosure(fn: fn).setCurry { a in [fn() as! AnyObject] }
}

func constrain<A: CN, B: CN, C: CN>(fn: (A, B) -> C) -> BaseClosure<(A, B), C> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self)) as! AnyObject]}
}

func constrain<A: CN, B: CN>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(try convert(a[0], to: A.self)) as! AnyObject]}
}

// Accepts any function
func accept<A, B>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn)
}




