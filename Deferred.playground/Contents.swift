/*:
# Deferred
Try out Deferred here!
*/
import Foundation
// @testable import Deferred

protocol Convertible {
    // Convert the given argument to this type. Assumes "T as? Self", has already been tried, or in other words checking
    // if no conversion is needed.
    static func to<T>(from: T) throws -> Self
    
    // Get a serializable value from this type
    func from() throws -> AnyObject
}


// Conversion methods should do all kinds of conversion in the absence of the deferred system
// This method is for single value targets and sources
// This works a lot like GSON for Android: give me something and tell me how you want it
public func convert<A, B>(from: A, to: B.Type) -> B? {
    
    for child in Mirror(reflecting: to).children {
        print(child)
    }
    
    // Catch a suprising majority of simple conversions where Swift can bridge or handle the type conversion itself
    if let simpleCast = from as? B {
        return simpleCast
    }
    
    // If B conforms to Convertible then the type has conversion overrides that may be able to handle the conversion
    if let convertible = B.self as? Convertible.Type {
        return try! convertible.to(from) as? B
    }
    
    for child in Mirror(reflecting: to).children {
        print(child)
    }
    
    return nil
}

let a = "a"
let b = convert(a, to: String.self)

let c = ("a", "b")
let d = convert(c, to: (String, String).self)!
print(d)


let m = Mirror(reflecting: (String, String).self)
print(m.children)