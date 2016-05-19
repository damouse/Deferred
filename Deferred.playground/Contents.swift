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


print(1)

class AbstractDeferred {
    // Once an callback or errback completes the result of the operation is stored here
    var results: [AnyObject]?
    
    // The closure this deferred wraps. It is either an errback or a callback closure
    var _invocation: AnyClosureType?
    
    // is this an error callback?
    var isError = false
    
    // The next link in the chain
    var next: [AbstractDeferred] = []
    
    
    func _then<T: AbstractDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        nextDeferred._invocation = fn
        
        if let a = results { nextDeferred.callback(a) }
        return nextDeferred
    }
    
    func _error<T: AbstractDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        nextDeferred._invocation = fn
        nextDeferred.isError = true
        
        if let a = results { nextDeferred.errback(a) }
        return nextDeferred
    }
    
    // Invoke our closure, store the results of the function, and pass those results to every deferred down the chain
    // If no closure exists then the arguments are stored as the results. If the callback throws an error then fire errback
    func callback(args: [AnyObject]) {
        if _invocation != nil && !isError {
            do {
                results = try _invocation!.call(args)
            } catch let e {
                errback(["\(e)"])
                return
            }
        } else {
            results = args
        }
        
        // TODO: deferred value transformation
        for n in next { n.callback(results!) }
    }
    
    func errback(args: [AnyObject]) {
        if _invocation != nil && isError{
            do {
                results = try _invocation!.call(args)
            } catch let e {
                results = ["\(e)"]
            }
        } else {
            results = args
        }
        
        // TODO: deferred value transformation
        for n in next { n.errback(results!) }
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

let d = Deferred<Void>()

d.then {
    print(2)
}

d.callback([])

























