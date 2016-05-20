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
        
        let d = Deferred<Void>()
        
        d.error { e in
            print("first error")
        }.error { e in
            print("second error")
        }
        
        d.errback([""])
    }
}

