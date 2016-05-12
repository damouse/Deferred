/*:
# Deferred
Try out Deferred here!
*/
import Foundation
@testable import Deferred

// Conversion methods should do all kinds of conversion in the absence of the deferred system 
// This method is for single value targets and sources
// This works a lot like GSON for Android
func convert<A: AnyObject, B>(from: A, to: B.Type) throws -> B {
    
    // Catch a suprising majority of simple conversions where Swift can bridge or handle the type conversion itself
    if let simpleCast = from as? B {
        return simpleCast
    }
    
    // TODO: catch errors that convertible might through
    if let convertible = B.self as? Convertible.Type {
        return convertible.to(from) as! B
    }
    
    throw ConversionError.NoConversionPossible(type: to.self)
}

let a = NSString(string: "a")

try! convert(a, to: String.self)

// Next:
//  write tests for dumb single value conversions
//  copy basic conversion extensions for JSON classes 
//  write serialization method


// Scratch and playground
// Note that using AnyObject above means no tuples, structs, and enums. Might have to drop back to full blown generics or Any
// It may be possible to use Mirrors on tuples and arrays in similar ways, however.
let someTuple: Any = (1, 2)

for c in Mirror(reflecting: someTuple).children {
    print(c)
}

let someFunc = { (a: Int, b: String) in
    
}

