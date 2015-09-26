//
//  BlockList.swift
//  BlockIn
//
//  Created by Andrew Ford on 25/09/15.
//  Copyright © 2015 Andrew Ford. All rights reserved.
//

import Foundation
import SafariServices

class BlockList {
    
    let fileBlockList = "blockerList.json"

    let whiteListTemplate: String = ""
    let defaults = NSUserDefaults.standardUserDefaults()
    let blockListKey = "BlacklistUrls"
    
    func refreshBlockList() {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("andrewford.com.BlockIn.ContentBlocker",
            completionHandler:{(error: NSError?) in
                print ("SFContentBlockerManager.reloadContentBlockerWithIdentifier")
                print (error?.localizedDescription)
        })
    }
    
    
    func writeFile() {
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileBlockList);
            
            //writing
            do {
                let jsonString = buildRulesJson()
                try jsonString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
            
            //reading
//            do {
//                let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
//            }
            //catch {/* error handling here */}
        }
    }
    
    func buildRulesJson() -> String {
        
        let blockListArray = getBlockListArray()
        var stringOfJson = ""
        
        // For loop for array
        
        // use template of 
        // {"action": {"type": "block"}, "trigger": {"url-filter": ".*", "resource-type": ["script"], "load-type": ["third-party"], "if-domain": ["*techcrunch.com"] } }
        
        // append to string
        
        // prefix of [
        
        // suffix of ]
        
         return stringOfJson
    }

    func saveBlockListUrl(url:String) {
    
        var currentArry = getBlockListArray()
        
        currentArry.append(url)
        
        defaults.setObject(currentArry, forKey: blockListKey)
    }
    
    func getBlockListArray() -> [String] {
        let array = defaults.objectForKey(blockListKey) as? [String] ?? [String]()
        
        return array
    }
}