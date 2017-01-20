//
//  SearchResult.swift
//  Aware
//
//  Created by Cas van der Hoven on 15/01/2017.
//  Copyright © 2017 Cas van der Hoven. All rights reserved.
//

import Foundation

class CompanyItem: NSObject, NSCoding {
    var status = ""
    var brand = ""
    var text = ""
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(status, forKey: "Status")
        aCoder.encode(brand, forKey: "Brand")
        aCoder.encode(text, forKey: "Text")
    }
    
    required init?(coder aDecoder: NSCoder) {
        status = aDecoder.decodeObject(forKey: "Status") as! String
        brand = aDecoder.decodeObject(forKey: "Brand") as! String
        text = aDecoder.decodeObject(forKey: "Text") as! String
        
        super.init()
    }
    
    override init() {
        super.init()
    }
}
