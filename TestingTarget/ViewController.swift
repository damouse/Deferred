//
//  ViewController.swift
//  TestingTarget
//
//  Created by damouse on 5/18/16.
//  Copyright © 2016 I. All rights reserved.
//

import UIKit
import Deferred
import SwiftyJSON
import Alamofire

// Tests hit the sample API at http://jsonplaceholder.typicode.com/

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Tester loaded")
        
        let url = "http://jsonplaceholder.typicode.com/posts/1"
        
        Alamofire.request(.GET, url).json("title") { (post: String) -> () in
            print("Have post with title: \(post)")
        }.error { e in
            print("Error occured: \(e)")
        }
        
//        Alamofire.request(.GET, "http://jsonplaceholder.typicode.com/posts/1", parameters: ["foo": "bar"])
//            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
//                
//                if let JSON = response.result.value {
//                    print("JSON: \(JSON)")
//                }
//        }
    }
}

