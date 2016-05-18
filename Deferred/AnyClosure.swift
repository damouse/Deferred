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


public enum ClosureError : ErrorType, CustomStringConvertible {
    case ExecutorNotSet()
    case BadNumberOfArguments(expected: Int, actual: Int)
    
    public var description: String {
        switch self {
        case .ExecutorNotSet(): return "Cannot invoke function without the curried executor that actually fires it. If using BaseClosure directly, did you call setExecutor after initializing?"
        case .BadNumberOfArguments(expected: let expected, actual: let actual): return "Expected  \(expected) arguments, got \(actual)"
        }
    }
}

// Any possible closure. This allows you to create lists like [AnyClosure] where each of the internal closures have their own signatures
protocol AnyClosureType {
    func call(args: [AnyObject]) throws -> [AnyObject]
}

protocol ClosureType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    var handler: ParameterTypes -> ReturnTypes { get }
}


// Concrete and invokable closure wrapper. Doesnt care about types and doesnt constrain its internal generics
// Note that this class is marked "Abstract" because its not ready out of the box-- a curried executor *must* be
// set by subclasses
public class BaseClosure<A, B>: AnyClosureType, ClosureType {
    public let handler: A -> B
    
    // This is the method that forwards an invocation to the true closure above
    // We don't have a way of capturing and enforcing the "true" type information from generic paramters, so the
    // invocation must be manually forwarded, likely in a subclass or factory
    private var executor: ([AnyObject] throws -> [AnyObject])?
    
    
    // For some reason the generic constraints aren't forwarded correctly when
    // the curried function is passed along, so it gets its own method below
    // You MUST call setExecutor immediately after init! Pretend its attached to the init method
    public init(fn: A -> B) {
        handler = fn
    }
    
    // You MUST call this method after initializing
    public func setExecutor(fn: [AnyObject] throws -> [AnyObject]) -> Self {
        executor = fn
        return self
    }
    
    public func call(args: [AnyObject]) throws -> [AnyObject] {
        guard let curry = executor else { throw ClosureError.ExecutorNotSet() }
        return try curry(args)
    }
}



// A closure wrapper factory that automatically wraps the handler in an executor.
// Does not enforce constraints on allowed types. Strangely this method errs on BaseClosure
public class Closure {
    
    // This is a special case, since it covers cases where either or both A and B can be Void.
    public static func wrap<A, R>(fn: A -> R) -> BaseClosure<A, R> {
        return BaseClosure(fn: fn).setExecutor { a in
            if A.self == Void.self  {
                if a.count != 0 { throw ClosureError.BadNumberOfArguments(expected: 0, actual: a.count) }
            } else {
                if a.count != 1 { throw ClosureError.BadNumberOfArguments(expected: 1, actual: a.count) }
            }
            
            let result = A.self == Void.self ? fn(() as! A) : fn(try convert(a[0], to: A.self))
            return R.self == Void.self ? [] : [result as! AnyObject]
        }
    }
    
    public static func wrap<A, B, R>(fn: (A, B) -> R) -> BaseClosure<(A, B), R> {
        return BaseClosure(fn: fn).setExecutor { a in
            if a.count != 2 { throw ClosureError.BadNumberOfArguments(expected: 2, actual: a.count) }
            let ret = fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self))
            return [ret as! AnyObject]
        }
    }
    
    public static func wrap<A, B, C, R>(fn: (A, B, C) -> R) -> BaseClosure<(A, B, C), R> {
        return BaseClosure(fn: fn).setExecutor { a in
            if a.count != 3 { throw ClosureError.BadNumberOfArguments(expected: 3, actual: a.count) }
            let ret = fn(try convert(a[0], to: A.self), try convert(a[1], to: B.self), try convert(a[2], to: C.self))
            return [ret as! AnyObject]
        }
    }
}

