//
//  BlackListTableViewController.swift
//  BlockIn
//
//  Created by Andrew Ford on 27/09/15.
//  Copyright © 2015 Andrew Ford. All rights reserved.
//

import UIKit
import SafariServices

class BlackListTableViewController: UITableViewController {
    
    var blockListArray = []
    let fileBlockList = "blockerList.json"
    let whiteListTemplate: String = ""
    let defaults = NSUserDefaults.init(suiteName: "group.andrewford.com.BlockIn")
    let blockListKey = "BlacklistUrls"
    let lastListUpdated = "LastListUpdated"
    let lastJsonUpdated = "LastJsonUpdated"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blockListArray = getBlockListArray()
        self.tableView.reloadData()
        
        // Hides empty table cells
        self.tableView.tableFooterView = UIView.init()

        writeFile()
        
        refreshBlockList()
        
        refreshControl?.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)

    }
    
    func refreshData() {
        self.blockListArray = getBlockListArray()
        
        writeFile()
        
        refreshBlockList()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return blockListArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BlackListCell") as! BlackListTableViewCell

        let site = blockListArray[indexPath.row] as! String
        
        // Configure the cell...
        cell.configureCell(site)

        return cell
    }



    
    // MARK: - JSON/NSUserDefault classes
    func refreshBlockList() {
        SFContentBlockerManager.reloadContentBlockerWithIdentifier("andrewford.com.BlockIn.ContentBlocker",
            completionHandler:{(error: NSError?) in
                print ("SFContentBlockerManager.reloadContentBlockerWithIdentifier")
                print (error?.localizedDescription)
        })
    }
    
    
    func writeFile() {
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(fileBlockList)
            
            guard let lastListUpDate = defaults!.objectForKey(lastListUpdated) as! NSDate? else { return }
            
            var lastWriteDate = NSDate()
            
            if let lastJsonUpdatedDate = defaults!.objectForKey(lastJsonUpdated) as! NSDate? {
                lastWriteDate = lastJsonUpdatedDate
            }
            else {
                let dataString = "April 7, 2002" as String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy"
                dateFormatter.timeZone = NSTimeZone.localTimeZone()
                
                lastWriteDate = dateFormatter.dateFromString(dataString) as NSDate!
            }

            if (lastListUpDate.compare(lastWriteDate) == NSComparisonResult.OrderedDescending) {
                
                // writing
                do {
                    
                    
                    let jsonString = buildRulesJson()
                    try jsonString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                    
                    // Set last update
                    let currentDate = NSDate()
                    defaults!.setObject(currentDate, forKey: lastJsonUpdated)
                    
                }
                catch {
                    /* error handling here */
                    print("An error occured")
                }
            }
        }
    }
    
    func buildRulesJson() -> String {
        
        let blockListArray = getBlockListArray()
        var stringOfJson = ""
        
        // For loop for array
        for url:String in blockListArray {
            // use template and append
            stringOfJson += "{\"action\": {\"type\": \"block\"}, \"trigger\": {\"url-filter\": \".*\", \"resource-type\": [\"script\"], \"load-type\": [\"third-party\"], \"if-domain\": [\"\(url)\"] } }"
        }
        
        // prefix of [
        stringOfJson = "[" + stringOfJson
        
        // suffix of ]
        stringOfJson = stringOfJson + "]"
        
        return stringOfJson
    }
    
    func saveBlockListUrl(url:String) {
        
        var currentArry = getBlockListArray()
        
        currentArry.append(url)
        
        // Set arrary to NSDefaults
        defaults!.setObject(currentArry, forKey: blockListKey)
        
        // Set last update
        let currentDate = NSDate()
        defaults!.setObject(currentDate, forKey: lastListUpdated)
    }
    
    func getBlockListArray() -> Array<String> {
        
        return defaults!.objectForKey(blockListKey) as? [String] ?? [String]()
        
    }

    
}
