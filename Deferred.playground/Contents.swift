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
        
        // Not handled: error branching and chaining
        if let cb = _callback {
            do {
                let ret = try cb.call(args)
                for n in next { n.callback(ret) }
            } catch let e {
                for n in next { n.errback(["\(e)"]) }
            }
        }
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
        return _then(Closure.wrap(fn), nextDeferred: DDeferred<Void>())
    }
    
    func then<T>(fn: A -> DDeferred<T>)  -> DDeferred<T> {
        let next = DDeferred<T>()
        
        if A.self == Void.self {
            _callback = Closure.wrap {
                fn(() as! A).next.append(next)
            }
        } else {
            _callback = Closure.wrap { (a: A) in
                print(1)
                
                fn(a).then { s in
                    print("chained block")
                    s is Void ? next.callback([]) : next.callback([s as! AnyObject])
                }.error { s in
                    print("chained err")
                    next.errback([s])
                }
            }
        }
        
        return next
    }
}

let d = DDeferred<Void>()
let e = DDeferred<String>()

let c = d.then { () -> DDeferred<String> in
    print("First fire")
    return e
}

c.then { s in
    print(s)
}
    
c.error {
    print($0)
}

d.callback([])
e.callback(["Done"])

