/*:
# Deferred
Try out Deferred here!
*/
import Foundation
@testable import Deferred


let c = Closure.wrap { (a: String) in
    print("b")
}

try! c.call(["Hello!"])







