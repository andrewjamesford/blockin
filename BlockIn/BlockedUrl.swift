//
//  BlockedUrl.swift
//  BlockIn
//
//  Created by Andrew Ford on 26/09/15.
//  Copyright © 2015 Andrew Ford. All rights reserved.
//

import Foundation

class BlockedUrl: NSObject {
    var blackListUrl: String
    
    init(url: String, name: String){
        self.blackListUrl = url
    }
    
    required init(coder aDecoder: NSCoder) {
        self.blackListUrl = aDecoder.dec("url")
    }
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(blackListUrl, forKey: "url")
    }
}