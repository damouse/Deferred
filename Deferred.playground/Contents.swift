/*:
# Deferred
Try out Deferred here!
*/
import Foundation
@testable import Deferred

protocol TestingConvertible {
    // Convert the given argument to this type. Assumes "T as? Self", has already been tried, or in other words checking
    // if no conversion is needed.
    static func testingTo<T>(from: T) throws -> Self
}

extension Array: TestingConvertible {
    static func testingTo<T>(from: T) throws -> Array {
        
        // Convert each element of the array
        if let from = from as? NSArray {
            var ret: [Element] = []
            
            for element in from {
                ret.append(try convert(element, to: Element.self))
            }
            
            return ret
        }
        
        throw ConversionError.ConvertibleFailed(from: T.self, type: self)
    }
}


// Conversion methods should do all kinds of conversion in the absence of the deferred system
// This method is for single value targets and sources
// This works a lot like GSON for Android
func liveConvert<A, B>(from: A, to: B.Type) throws -> B {
    // Catch a suprising majority of simple conversions where Swift can bridge or handle the type conversion itself
    if let simpleCast = from as? B {
        print("Cast worked")
        return simpleCast
    }
    
    // TODO: catch errors that convertible might through
    if let convertible = B.self as? TestingConvertible.Type {
        print("Convertible worked")
        return try convertible.testingTo(from) as! B
    }
    
    throw ConversionError.NoConversionPossible(from: A.self, type: to.self)
}


let a: [NSString] = [NSString(string: "asdf"), NSString(string: "qwer")]

do {
    let b = try liveConvert(a, to: [String].self)
} catch {
    print("Failed")
}

// Next:
//  write tests for dumb single value conversions
//  copy basic conversion extensions for JSON classes 
//  write serialization method

// Questions: 
//  Does AnyObject matter here?

