/*:
# Deferred
Try out Deferred here!
*/
import Foundation

// This no longer works after importing external pods :(
// This file is here for inline testing
import Deferred
//
//
//// Oooh, may have made a mistake. We'd like to take ANY deferred, the caller doesn't care about the types!
//// Key to the changes are how the deferred accepts callback arguments. Somewhere key ordering has to be passed in 
//// I don't know if Deferred is a good place to receive that information...
//
//// Steps for changes: 
////      Create new dynamic deferred class 
////      Class .then can accept an ordered list of keys that match the params and types within handler 
////      When called with dictionary, keys are matched and raw json is ordered
//
//// Not handled: nested raw dictionary schemas. I think?
//
////networkCall() -> ReceivingDeferred
////
////networkCall().then("a", "b") { (a: Int, b: String) in
////    
////}
//
//
//let d = JSONDeferred()
//
//d.then("keyA", "keyB") { (a: String, b: Int) -> () in
//    
//}


class Dog {
    var age = 12
    
    func bark() {
        print("Im \(age)")
    }
}

protocol Base {
    var age: Int { get set }
}

protocol Mortal: Base {
    associatedtype Animal
}

extension Mortal {
    mutating func grow() {
        age += 1
    }
    
    func create() -> Animal.Type {
        return Animal.self
    }
}


extension Dog: Mortal {
    typealias Animal = Dog
}

var d = Dog()
d.grow()
d.bark()

d.create()


