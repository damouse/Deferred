/*:
# Deferred
Try out Deferred here!
*/
import Foundation
@testable import Deferred

func constrainer<A, B>(fn: A -> B)  -> BaseClosure<A, B> {
    // return BaseClosure(fn: fn).setCurry { a in return [fn(try convert(a[0], to: A.self)) as! AnyObject]}
    return BaseClosure(fn: fn).setCurry { a in
        if A.self == Void.self {
            fn(() as! A)
        } else {
            fn(try convert(a[0], to: A.self))
        }
        
        return []
    }
}


let a = constrain() {
    print("Hi!")
}

try! a.call([])

