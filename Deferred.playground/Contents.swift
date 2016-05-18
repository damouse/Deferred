/*:
# Deferred
Try out Deferred here!
*/
import Foundation
@testable import Deferred

class AbDeferred {
    // Automatically invoke callbacks and errbacks if not nil when given arguments
    var callbackArgs: [AnyObject]?
    var errbackArgs: [AnyObject]?
    
    // If an invocation has already occured then the args properties are already set
    // We should invoke immediately
    var _callback: AnyClosureType?
    var _errback: AnyClosureType?
    
    // The next link in the chain
    var next: [AbDeferred] = []
    
    
    func _then<T: AbDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        if let a = callbackArgs { try? fn.call(a) }
        _callback = fn
        return nextDeferred
    }
    
    func _error<T: AbDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        _errback = fn
        if let a = errbackArgs { errback(a) }
        return nextDeferred
    }
    
    func callback(args: [AnyObject]) {
        callbackArgs = args
        var ret: [AnyObject] = []
        if let cb = _callback { ret = try! cb.call(args) }
        for n in next { n.callback(ret) }
    }
    
    func errback(args: [AnyObject]) {
        errbackArgs = args
        if let eb = _errback { try! eb.call(args) }
        for n in next { n.errback(args) }
    }
    
    func error(fn: String -> ()) -> DDeferred<Void> {
        return _error(Closure.wrap(fn), nextDeferred: DDeferred<Void>())
    }
}


class DDeferred<A>: AbDeferred {
    func then(fn: A -> ())  -> DDeferred<Void> {
        print("Current next list: \(next)")
        return _then(Closure.wrap(fn), nextDeferred: DDeferred<Void>())
    }
    
    func chain(fn: () -> DDeferred) -> DDeferred<Void> {
        let next = DDeferred<Void>()
        
        _callback = Closure.wrap {
            fn().next.append(next)
        }
        
        return next
    }
    
    func chain<T>(fn: A -> DDeferred<T>)  -> DDeferred<T> {
        let next = DDeferred<T>()
        
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

let d = DDeferred<Void>()

d.then {
    print("On Time")
}

d.callback([])

d.then {
    print("Lazy")
}


