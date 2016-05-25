//
//  AlamoFire+Deferred.swift
//  Deferred
//
//  Created by damouse on 5/23/16.
//  Copyright © 2016 I. All rights reserved.
//
//  A quick and simple extension around AlamoFire that demonstrates Deferred usage. It can be used standalone
//  No changes to Alamo, other than returning deferreds instead of accepting handler blocks

import Foundation
import Alamofire
import SwiftyJSON

// Extend the request object as returned by Alamo to accept deferreds
public extension Request {
    func json<A>(keyOne: String, fn: A -> ()) -> JSONDeferred {
        let d = JSONDeferred()
        d.json(keyOne, fn: fn)
        
        // reassign the request handler with a forwarder into the Deferred object
        responseData() { r in
            if r.result.error != nil {
                d.errback([r.result.error!.description])
            }
            
            // I'm not convinced we should do our own parsing here, but sticking with it for testing
            let json = JSON(data: r.data!)
            
            guard let dict = json.dictionaryObject else {
                d.errback(["Couldn't unpack the JSON"])
                return
            }
            
            d.callback(dict)
        }
        
        return d
    }
}