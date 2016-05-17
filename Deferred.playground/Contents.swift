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
    
    throw ConversionError.NoConversionPossible(from: A.self, type: to.self)
}

let a: NSNumber = 123.456
let b = try! convert(a, to: Float.self)
print(b.dynamicType)

// Next:
//  write tests for dumb single value conversions
//  copy basic conversion extensions for JSON classes 
//  write serialization method

// Questions: 
//  Does AnyObject matter here?