//
//  DSON.swift
//  Deferred
//
//  Created by damouse on 5/18/16.
//  Copyright © 2016 I. All rights reserved.
//  Damouse's GSON

import Foundation
import SwiftyJSON


public func testJson() {
    print("Tester loaded")
    
    let raw = "{\"menu\": {\n  \"id\": \"file\",\n  \"value\": \"File\",\n  \"popup\": {\n    \"menuitem\": [\n      {\"value\": \"New\", \"onclick\": \"CreateNewDoc()\"},\n      {\"value\": \"Open\", \"onclick\": \"OpenDoc()\"},\n      {\"value\": \"Close\", \"onclick\": \"CloseDoc()\"}\n    ]\n  }\n}}".dataUsingEncoding(NSUTF8StringEncoding)
    
    // let data: NSData = try! json.rawData()
    
    let json = JSON(data: raw!)
    print(json)
}


// The unpack methods take raw json and some schema, convert the json to the schema and return it



// Note that single models are handled directly through Convertible. This is specifically for direct, literal json 
