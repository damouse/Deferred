//
//  AnyFunction.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//  Generic wrappers that allow "AnyFunction" to be accepted and constrained by type and number of parameters

import Foundation


protocol AnyClosureType {
    func call(args: [AnyObject]) -> [AnyObject]
}

protocol ClosureType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    var handler: ParameterTypes -> ReturnTypes { get }
}

// Concrete and invokable. Doesn't care about types
class BaseClosure<A, B>: AnyClosureType, ClosureType {
    let handler: A -> B
    var curried: ([AnyObject] -> [AnyObject])!
    
    // For some reason the generic constraints aren't forwarded correctly when
    // the curried function is passed along, so it gets its own method below
    // You must call setCurry immediately after init!
    init(fn: A -> B) {
        handler = fn
    }
    
    func call(args: [AnyObject]) -> [AnyObject] {
        return curried(args)
    }
    
    func setCurry(fn: [AnyObject] -> [AnyObject]) -> Self {
        curried = fn
        return self
    }
}

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
            fn(a[0] as! A)
        }
        
        return []
    }
}

func constrainVoidOne<A>(fn: () -> A) -> BaseClosure<Void, A> {
    return BaseClosure(fn: fn).setCurry { a in [fn() as! AnyObject] }
}

func constrain<A: CN, B: CN, C: CN>(fn: (A, B) -> C) -> BaseClosure<(A, B), C> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(try! A.to(a[0]), try! B.to(a[1])) as! AnyObject]}
}

func constrain<A: CN, B: CN>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(try! A.to(a[0])) as! AnyObject]}
}

func accept<A, B>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn)
}




