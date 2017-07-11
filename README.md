# Deferred

This is a Deferred implementation for Swift heavily inspired by Python Twisted and Promise/A+. It also takes a lot of influence from ReactiveCocoa in managing value transformation and pipelining. 

This project was written for Swift 1.3 and has not been updated for Swift 3. I currently don't have plans to update it. 

Fundementally, Deferred orchestrates handler function invocation by chaining handlers togeterh, converting or serializing data, and managing errors. Its primary focus is making asynchronous code (especially networking code) easier to deal with, but isn't tied to any networking library implementation. 

## Examples
```swift
import Deferred

// Create a new deferred
var d = Deferred<Void>()

// Build the chain. Values are passed down and transformed based on parameter types
// The next deferreds in the chain do not require signatures, their type is inferred from the previous 
// deferred's return type
d.chain { () -> Deferred<String> in
    print(1)
    return f
}.then { s in
    print(s)
    print(2)
}.then {
    print(3) // I dont take any args, since the block above me didnt reutn a deferred
}.error { err in
    print("Error: \(err)")
}

// Fire the callback 
d.callback([])
```

This is a library for dealing with asynchronous operations. Here's a more tangible example with AF:
```swift
  Alamofire.request(.GET, url).json("title") { (post: String) -> () in
      // Loaded a single post. Request the rest of the article
      return Alamofire.request(.GET, url).json("article)
  }.chain { (article: String) -> () in
    // Loaded the article. Return it as an array of words
    return article.split(' ')
  }.then { words in
    print("Have words!")
  }.error { e in
      print("Error occured: \(e)")
  }
```

## Progress and Features

Featurelist: 

- Automated conversion
- Conversion of optionals allowing nil to pass through 
- Basic conversion Deferreds
- `AnyFunction` generic receiver and factory methods
- Models (implemented as part of Silvery)




