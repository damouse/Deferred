//
//  TypedDeferred.swift
//  Deferred
//
//  Created by damouse on 5/23/16.
//  Copyright © 2016 I. All rights reserved.
//

import Foundation

public enum JSONDeferredError : ErrorType, CustomStringConvertible {
    case BadArgumentNumber(count: Int)
    case BadArgumentType(type: Any.Type)
    case KeyNotFound(expected: String, dict: [String: AnyObject])
    
    public var description: String {
        switch self {
        case .BadArgumentNumber(count: let count): return "JSON deferreds expect one argument passed into \"callback\", got \(count)"
        case .BadArgumentType(type: let type): return "JSONdeferred requires a dictionary, but got \(type)"
        case .KeyNotFound(expected: let expected, dict: let dict): return "Could not find key \(expected) in \(dict)"
        }
    }
}


public class BaseTypedDeferred: AbstractDeferred {
    public func error(fn: String -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrap(fn), isSuccess: false, next: Deferred<Void>())
    }
}

// Deferreds can take any kind of arguments or returns, which is a little scary
// The intended way for customizing this behavior is by putting generic constraints on subclasses

// This is the most open ended one and accepts anything for its first "then"

public class JSONDeferred: BaseTypedDeferred {
    var keys: [String] = []
    override public init() {}
    
    // The special sauce in this class. Maps a list of one element, a dictionary, into an ordered list of arguments that match the
    // closure's order as dictated by the "then" functions. 
    //
    // Args must have one object, it must be a dictionary, and number of keys passed into "then" must be present within the dict.
    // If any of these conditions are not met then the errback is fired
    public override func callback(args: [AnyObject]) {
        if args.count != 1 {
            return errback([JSONDeferredError.BadArgumentNumber(count: args.count).description])
        }
        
        guard let json = args[0] as? [String: AnyObject] else {
            return errback([JSONDeferredError.BadArgumentType(type: args[0].dynamicType).description])
        }
        
        callback(json)
    }
    
    public func callback(json: [String: AnyObject]) {
        var results: [AnyObject] = []
        
        for k in keys {
            guard let value = json[k] else {
                return errback([JSONDeferredError.KeyNotFound(expected: k, dict: json).description])
            }
            
            results.append(value)
        }
        
        
        fire(results, successfully: true)
    }
    
    // These methods accept a list of positional strings that represent keys in a JSON object. The order of the
    // keys must match the order of parameters in the closure
    public func json(fn: () -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    public func json(fn: () -> Deferred<Void>) -> Deferred<Void> {
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    // One
    public func json<A>(keyOne: String, fn: A -> ()) -> Deferred<Void> {
        keys = [keyOne]
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    public func json<A>(keyOne: String, fn: A -> Deferred<A>) -> Deferred<A> {
        keys = [keyOne]
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<A>())
    }
    
    // Two params
    public func json<A, B>(keyOne: String, _ keyTwo: String,  fn: (A, B) -> ()) -> Deferred<Void> {
        keys = [keyOne, keyTwo]
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    public func json<A, B>(keyOne: String, _ keyTwo: String,  fn: (A, B) -> DeferredTwo<A, B>) -> DeferredTwo<A, B> {
        keys = [keyOne, keyTwo]
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: DeferredTwo<A, B>())
    }
}



// All typed deferreds extend BaseTyped and essentially reimplement its "then" methods based on the number of generic parameters
public class Deferred<A>: BaseTypedDeferred {
    override public init() {}
    
    public func then(fn: A -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    // Oof, we're going to have to duplicate these, too...
    public func then<T>(fn: A -> Deferred<T>) -> Deferred<T> {
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<T>())
    }
}

public class DeferredTwo<A, B>: BaseTypedDeferred {
    public func then(fn: (A, B) -> ()) -> Deferred<Void> {
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<Void>())
    }
    
    public func then<T>(fn: (A, B) -> Deferred<T>) -> Deferred<T> {
        return convenienceLink(Closure.wrap(fn), isSuccess: true, next: Deferred<T>())
    }
}