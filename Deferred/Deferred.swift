//
//  DeferredProtocol.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//

import Foundation


class AbstractDeferred {
    // Automatically invoke callbacks and errbacks if not nil when given arguments
    var callbackArgs: [AnyObject]?
    var errbackArgs: [AnyObject]?
    
    // If an invocation has already occured then the args properties are already set
    // We should invoke immediately
    var _callback: AnyClosureType?
    var _errback: AnyClosureType?
    
    // The next link in the chain
    var next: [AbstractDeferred] = []
    
    
    func _then<T: AbstractDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        
        // This isnt correct and likely doesnt account for the failure cases well
        // if let a = callbackArgs { callback(a) }
        if let a = callbackArgs { _ = try? fn.call(a) }
        
        // Also we don't want to replace the callback here if the args are set, want to branch the chain instead
        _callback = fn
        
        return nextDeferred
    }
    
    func _error<T: AbstractDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        _errback = fn
        if let a = errbackArgs { errback(a) }
        return nextDeferred
    }
    
    func callback(args: [AnyObject]) {
        callbackArgs = args
        var ret: [AnyObject] = []
        
        // Not handled: error branching and chaining
        if let cb = _callback { ret = try! cb.call(args) }
        for n in next { n.callback(ret) }
    }
    
    func errback(args: [AnyObject]) {
        errbackArgs = args
        if let eb = _errback { try! eb.call(args) }
        for n in next { n.errback(args) }
    }
    
    func error(fn: String -> ()) -> Deferred<Void> {
        return _error(Closure.wrap(fn), nextDeferred: Deferred<Void>())
    }
}


class Deferred<A>: AbstractDeferred {
    func then(fn: A -> ())  -> Deferred<Void> {
        return _then(Closure.wrap(fn), nextDeferred: Deferred<Void>())
    }
    
    func chain(fn: () -> Deferred) -> Deferred<Void> {
        let next = Deferred<Void>()
        
        _callback = Closure.wrap {
            fn().next.append(next)
        }
        
        return next
    }
    
    
    func chain<T>(fn: A -> Deferred<T>)  -> Deferred<T> {
        let next = Deferred<T>()
        
        _callback = Closure.wrap { (a: A) in
            fn(a).then { s in
                next.callback([s as! AnyObject])
            }.error { s in
                next.errback([s])
            }
        }
        
        return next
    }
}


// NEW CODE

/**
 Implements basic shared deferrred functionality, including:
 Holding a closure called the handler
 Holding references to the next links in the deferred chain
 "Firing" the chain in success or in error
 Storing the results of its internal closure after firing and presenting them lazily to subsequent links
 Waiting for "intercession" deferreds, or deferreds returned from the handler
 
 See inline comments for more info about functionality.
 
 Why is this class marked as abstract? You could use it directly if you had scoped access to _then and _error,
 the methods that set the handler closure and create new links in the chain, but subclasses are expected to
 provide their own implementation of these methods
 */
public class AAbstractDeferred {
    // The closure this deferred wraps, representing a success or failure callback
    private var handler: AnyClosureType?
    public private(set) var isSuccess: Bool
    
    // Success or failure state of handler as well as its results
    public private(set) var didSucceed: Bool?
    private var results: [AnyObject]?
    
    private var chain: [AAbstractDeferred] = []
    
    
    public init(handler: AnyClosureType?, asSuccess: Bool) {
        self.handler = handler
        isSuccess = asSuccess
    }
    
    
    // Take a new handler and deferred, assign the handler to the deferred, and link the defferred to the chain
    // If this deferred already has results then fire the new deferred immediately
    public func link<T: AAbstractDeferred>(next: T) -> T {
        chain.append(next)
        
        if let a = results {
            if next.isSuccess {
                next.errback(a)
            } else {
                next.callback(a)
            }
        }
        
        return next
    }
    
    // Invoke this deferred with the given parameters
    // didSucceed must be set before calling this method. This determines whether or not the propogation is a success or error
    public func fire(args: [AnyObject], successfully: Bool) {
        if handler != nil {
            // Handler is only fired if isError and didSucceed are both true or both false
            if isSuccess && successfully || !isSuccess && !successfully {
                do {
                    results = try handler!.call(args)
                    
                    // If this is an error deferred then calling the handler successfully doesnt mean success,
                    // it means we continue to propagate errbacks down the chain
                    didSucceed = isSuccess
                } catch let e {
                    // TODO: recover from errors and represent them in a more palatable way
                    results = ["\(e)"]
                    didSucceed = false
                }
            }
            
        } else {
            // If no handler is assigned then just pass through the arguments as a "result"
            // Since we don't have a handler, assume this is a success case
            results = args
            didSucceed = true
        }
        
        // TODO: deferred value transformation
        
        for n in chain { n.fire(results!, successfully: didSucceed!) }
    }
    
    public func callback(args: [AnyObject]) {
        fire(args, successfully: true)
    }
    
    public func errback(args: [AnyObject]) {
        fire(args, successfully: false)
    }
}


public class DDeferred<A>: AAbstractDeferred {
    
    // The inheritance chokes, so this is explicitly overriden
    public override init(handler: AnyClosureType?, asSuccess: Bool) {
        super.init(handler: handler, asSuccess: asSuccess)
    }
    
    // This initializer is intended for users
    public convenience init() {
        self.init(handler: nil, asSuccess: true)
    }
    
    func error(fn: String -> ()) -> DDeferred<Void> {
        let d = DDeferred<Void>(handler: Closure.wrap(fn), asSuccess: false)
        link(d)
        return d
    }
    
    func then(fn: A -> ())  -> DDeferred<Void> {
        let d = DDeferred<Void>(handler: Closure.wrap(fn), asSuccess: true)
        link(d)
        return d
    }
}











