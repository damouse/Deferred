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

// Concrete and invokable closure wrapper. Doesnt care about types and doesnt constrain its internal generics
// Note that this class is marked "Abstract" because its not ready out of the box-- a curried executor *must* be
// set by subclasses
public class BaseClosure<A, B>: AnyClosureType, ClosureType {
    let handler: A -> B
    
    // This is the method that forwards an invocation to the true closure above
    // We don't have a way of capturing and enforcing the "true" type information from generic paramters, so the
    // invocation must be manually forwarded, usually in a subclass
    var curried: ([AnyObject] throws -> [AnyObject])!
    
    
    // For some reason the generic constraints aren't forwarded correctly when
    // the curried function is passed along, so it gets its own method below
    // You must call setCurry immediately after init!
    public init(fn: A -> B) {
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





