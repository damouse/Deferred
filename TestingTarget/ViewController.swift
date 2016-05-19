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
        
        let raw = "{\"menu\": {\n  \"id\": \"file\",\n  \"value\": \"File\",\n  \"popup\": {\n    \"menuitem\": [\n      {\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},\n      {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},\n      {\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}\n    ]\n  }\n}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let json = JSON(data: raw!)
        
        print(json)
        
        let dict = json["menu"].dictionaryObject!
        
        print("Dict: \(dict["popup"].dynamicType)")
    }
}

