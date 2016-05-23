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

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Tester loaded")
        
        
        let d = JSONDeferred()
        
        d.json("alpha", "beta") { (a: String, b: Int) in
            print("Have \(a) \(b)")
        }
        
        d.callback([["alpha": "hello", "beta": 1]])
    }
}

