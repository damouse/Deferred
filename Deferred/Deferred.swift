//
//  DeferredProtocol.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//

import Foundation


public protocol DeferredType {
    // Connect the next deferred to this one as the next link in the chain. Next is called with the 
    // positive or negative results of this
    func link<T: DeferredType>(next: T)
    
    // Fire this deferred as a success or failure, respectively
    func callback(args: [AnyObject])
    func errback(args: [AnyObject])
}

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
public class AbstractDeferred: DeferredType {
    // The closure this deferred wraps, representing a success or failure callback
    var handler: AnyClosureType?
    public private(set) var isSuccess: Bool
    
    // Success or failure state of handler as well as its results
    public private(set) var didSucceed: Bool?
    var results: [AnyObject]?
    
    var chain: [DeferredType] = []
    
    
    public init(asSuccess: Bool, handler: AnyClosureType?) {
        self.handler = handler
        isSuccess = asSuccess
    }
    
    
    // Take a new handler and deferred, assign the handler to the deferred, and link the defferred to the chain
    // If this deferred already has results then fire the new deferred immediately
    public func link<T: DeferredType>(next: T) {
        chain.append(next)
        
        if let a = results {
            if didSucceed! {
                next.callback(a)
            } else {
                next.errback(a)
            }
        }
    }
    
    public func callback(args: [AnyObject]) {
        fire(args, successfully: true)
    }
    
    public func errback(args: [AnyObject]) {
        fire(args, successfully: false)
    }
    
    // Invoke this deferred with the given parameters
    // didSucceed must be set before calling this method. This determines whether or not the propogation is a success or error
    //
    // WARN: when a nested deferred is returned lazy links are going to immediately fire with the deferred instead of rerunning it.
    // Not a bug, just make sure this behavior is inteded
    func fire(args: [AnyObject], successfully: Bool) {
        
        // If we're being invoked with a deferred directly wait for that deferred to fire
        // WARN: by linking self to that deferred may refire our chain in strange ways
        if args.count == 1 && args[0] is DeferredType {
            let nesteDeferred = args[0] as! DeferredType
            nesteDeferred.link(self)
            return
        }
        
        // Handler is only fired if isError and didSucceed are both true or both false
        if handler != nil && (isSuccess && successfully || !isSuccess && !successfully) {
            do {
                results = try handler!.call(args)
                
                // If this is an error deferred then calling the handler successfully doesnt mean success,
                // it means we continue to propagate errbacks down the chain
                didSucceed = isSuccess
            } catch let e {
                // TODO: recover from errors and represent them real pretty like
                results = ["\(e)"]
                didSucceed = false
            }
        } else {
            // If no handler is assigned then just pass through the arguments as a "result"
            // Since we don't have a handler, assume this is a success case
            results = args
            didSucceed = successfully
        }
        
        for n in chain {
            if didSucceed! {
                n.callback(results!)
            } else {
                n.errback(results!)
            }
        }
    }
}


public class Deferred<A>: AbstractDeferred {
    
    // The inheritance chokes, so this is explicitly overriden
    public override init(asSuccess: Bool, handler: AnyClosureType?) {
        super.init(asSuccess: asSuccess, handler: handler)
    }
    
    // This initializer is intended for users
    public convenience init() {
        self.init(asSuccess: true, handler: nil)
    }
    
    
    func error(fn: String -> ()) -> Deferred<Void> {
        let d = Deferred<Void>(asSuccess: false, handler: Closure.wrap(fn))
        link(d)
        return d
    }
    
    func then(fn: A -> ()) -> Deferred<Void> {
        let d = Deferred<Void>(asSuccess: true, handler: Closure.wrap(fn))
        link(d)
        return d
    }
    
    func then<T>(fn: A -> Deferred<T>) -> Deferred<T> {
        let d = Deferred<T>(asSuccess: true, handler: Closure.wrap(fn))
        link(d)
        return d
    }
}











