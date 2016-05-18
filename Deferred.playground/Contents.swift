/*:
# Deferred
Try out Deferred here!
*/
import Foundation
@testable import Deferred

public class Fun {
    
    // This is a special case, since it covers cases where either or both A and B can be Void.
    public static func wrap<A, R>(fn: A -> R) -> BaseClosure<A, R> {
        return BaseClosure(fn: fn).setCurry { a in
            if A.self == Void.self  {
                if a.count != 0 { throw ConversionError.BadNumberOfArguments(expected: 0, actual: a.count) }
            } else {
                print(a.count)
                if a.count != 1 { throw ConversionError.BadNumberOfArguments(expected: 1, actual: a.count) }
            }
            
            let result = A.self == Void.self ? fn(() as! A) : fn(try convert(a[0], to: A.self))
            return R.self == Void.self ? [] : [result as! AnyObject]
        }
    }
}


let c = Fun.wrap {
    print("HI")
}

try! c.call([])

