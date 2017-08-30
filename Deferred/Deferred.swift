//
//  DeferredProtocol.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//

import Foundation
import AnyFunction

public protocol DeferredType {
    // Connect the next deferred to this one as the next link in the chain. Next is called with the 
    // positive or negative results of this
    func link<T: DeferredType>(_ next: T)
    
    // Fire this deferred as a success or failure, respectively
    func callback(_ args: [Any])
    func errback(_ args: [Any])
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
open class AbstractDeferred: DeferredType {
    // The closure this deferred wraps, representing a success or failure callback
    var handler: AnyClosureType?
    var isSuccess: Bool = false
    
    // Success or failure state of handler as well as its results
    open fileprivate(set) var didSucceed: Bool?
    var results: [Any]?
    
    var chain: [DeferredType] = []
    
    
    // Take a new handler and deferred, assign the handler to the deferred, and link the defferred to the chain
    // If this deferred already has results then fire the new deferred immediately
    // Returns the deferred passed in for convenience
    open func link<T: DeferredType>(_ next: T) {
        chain.append(next)
        
        if let a = results {
            if didSucceed! {
                next.callback(a)
            } else {
                next.errback(a)
            }
        }
    }
    
    // This is a convenience method written to make deferred linking cleaner to write in subclasses.
    // Because of the generic shotgun approach that subclasses take, these four lines are repeated *a lot*. Overrideing 
    // inits may work, but require all subclasses to have their own inits as well.
    open func convenienceLink<T: AbstractDeferred>(_ function: AnyClosureType, isSuccess: Bool, next: T) -> T {
        next.isSuccess = isSuccess
        next.handler = function
        link(next)
        return next
    }
    
    open func callback(_ args: [Any]) {
        fire(args, successfully: true)
    }
    
    open func errback(_ args: [Any]) {
        fire(args, successfully: false)
    }
    
    // Invoke this deferred with the given parameters
    // didSucceed must be set before calling this method. This determines whether or not the propogation is a success or error
    //
    // WARN: when a nested deferred is returned lazy links are going to immediately fire with the deferred instead of rerunning it.
    // Not a bug, just make sure this behavior is inteded
    func fire(_ args: [Any], successfully: Bool) {
        print("Fire invoked with: \(args)")
        
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
                
                // The final goal is to have errors return values and let the chain transform or conditionally handle them. 
                // For now the same error argument string is always passed around. Not the biggest fan of this, but there you go 
                if !isSuccess {
                    results = args
                }
                
                // If this is an error deferred then calling the handler successfully doesnt mean success,
                // it means we continue to propagate errbacks down the chain
                didSucceed = isSuccess
            } catch let e {
                // TODO: recover from errors and represent them real pretty like
                results = ["\(e)" as Any]
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
















































