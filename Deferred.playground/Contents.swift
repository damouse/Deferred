/*:
# Deferred
Try out Deferred here!
*/
import Foundation

// This no longer works after importing external pods :(
// This file is here for inline testing
import Deferred


// Oooh, may have made a mistake. We'd like to take ANY deferred, the caller doesn't care about the types!
// Key to the changes are how the deferred accepts callback arguments. Somewhere key ordering has to be passed in 
// I don't know if Deferred is a good place to receive that information...

// Steps for changes: 
//      Create new dynamic deferred class 
//      Class .then can accept an ordered list of keys that match the params and types within handler 
//      When called with dictionary, keys are matched and raw json is ordered

// Not handled: nested raw dictionary schemas. I think?

//networkCall() -> ReceivingDeferred
//
//networkCall().then("a", "b") { (a: Int, b: String) in
//    
//}


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
    public private(set) var didSucceed = false
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
                }
            }
            
        } else {
            // If no handler is assigned then just pass through the arguments as a "result"
            // Since we don't have a handler, assume this is a success case
            results = args
            didSucceed = true
        }
        
        // TODO: deferred value transformation
        
        for n in chain { n.fire(results!, successfully: didSucceed) }
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


let d = DDeferred<Void>()

d.then {
    print(2)
}

d.callback([])

























