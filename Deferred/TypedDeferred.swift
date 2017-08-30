//
//  TypedDeferred.swift
//  Deferred
//
//  Created by damouse on 5/23/16.
//  Copyright © 2016 I. All rights reserved.
//

import Foundation
import AnyFunction

public enum JSONDeferredError : Error, CustomStringConvertible {
    case badArgumentNumber(count: Int)
    case badArgumentType(type: Any.Type)
    case keyNotFound(expected: String, dict: [String: AnyObject])
    
    public var description: String {
        switch self {
        case .badArgumentNumber(count: let count): return "JSON deferreds expect one argument passed into \"callback\", got \(count)"
        case .badArgumentType(type: let type): return "JSONdeferred requires a dictionary, but got \(type)"
        case .keyNotFound(expected: let expected, dict: let dict): return "Could not find key \(expected) in \(dict)"
        }
    }
}


open class BaseTypedDeferred: AbstractDeferred {
    open func error(_ fn: @escaping (String) -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrapOne(fn), isSuccess: false, next: Deferred<Void>())
    }
}

// Deferreds can take any kind of arguments or returns, which is a little scary
// The intended way for customizing this behavior is by putting generic constraints on subclasses

// This is the most open ended one and accepts anything for its first "then"

open class JSONDeferred: BaseTypedDeferred {
    var keys: [String] = []
    override public init() {}
    
    // The special sauce in this class. Maps a list of one element, a dictionary, into an ordered list of arguments that match the
    // closure's order as dictated by the "json" functions.
    //
    // Args must have one object, it must be a dictionary, and number of keys passed into "then" must be present within the dict.
    // If any of these conditions are not met then the errback is fired
    open override func callback(_ args: [Any]) {
        if args.count != 1 {
            return errback([JSONDeferredError.badArgumentNumber(count: args.count).description])
        }
        
        guard let json = args[0] as? [String: AnyObject] else {
            return errback([JSONDeferredError.badArgumentType(type: type(of: args[0])).description])
        }
        
        callback(json)
    }
    
    open func callback(_ json: [String: AnyObject]) {
        var results: [AnyObject] = []
        
        for k in keys {
            guard let value = json[k] else {
                return errback([JSONDeferredError.keyNotFound(expected: k, dict: json).description])
            }
            
            results.append(value)
        }
        
        
        fire(results, successfully: true)
    }
    
    // These methods accept a list of positional strings that represent keys in a JSON object. The order of the
    // keys must match the order of parameters in the closure
    open func json(_ fn: @escaping () -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrapOne(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    open func json(_ fn: @escaping () -> Deferred<Void>) -> Deferred<Void> {
        return convenienceLink(Closure.wrapOne(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    // One
    open func json<A>(_ keyOne: String, fn: @escaping (A) -> ()) -> Deferred<Void> {
        keys = [keyOne]
        return convenienceLink(Closure.wrapOne(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    open func json<A>(_ keyOne: String, fn: @escaping (A) -> Deferred<A>) -> Deferred<A> {
        keys = [keyOne]
        return convenienceLink(Closure.wrapOne(fn), isSuccess: true, next: Deferred<A>())
    }
    
    // Two params
    open func json<A, B>(_ keyOne: String, _ keyTwo: String, fn: @escaping (A, B) -> ()) -> Deferred<Void> {
        keys = [keyOne, keyTwo]
        return convenienceLink(Closure.wrapTwo(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    open func json<A, B>(_ keyOne: String, _ keyTwo: String,  fn: @escaping (A, B) -> DeferredTwo<A, B>) -> DeferredTwo<A, B> {
        keys = [keyOne, keyTwo]
        return convenienceLink(Closure.wrapTwo(fn), isSuccess: true, next: DeferredTwo<A, B>())
    }
}



// All typed deferreds extend BaseTyped and essentially reimplement its "then" methods based on the number of generic parameters
open class Deferred<A>: BaseTypedDeferred {
    override public init() {}
    
    open func then(_ fn: @escaping (A) -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrapOne(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    // Oof, we're going to have to duplicate these, too...
    open func then<T>(_ fn: @escaping (A) -> Deferred<T>) -> Deferred<T> {
        return convenienceLink(Closure.wrapOne(fn), isSuccess: true, next: Deferred<T>())
    }
}

open class DeferredTwo<A, B>: BaseTypedDeferred {
    open func then(_ fn: @escaping (A, B) -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrapTwo(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    open func then<T>(_ fn: @escaping (A, B) -> Deferred<T>) -> Deferred<T> {
        return convenienceLink(Closure.wrapTwo(fn), isSuccess: true, next: Deferred<T>())
    }
}




