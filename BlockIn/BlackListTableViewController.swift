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
    let fileBlockList = "blockerList"
    let fileExtension = "json"
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

        checkBlockFile()
        
        //copyFile()
        //writeFile()
        
        //refreshBlockList()
        
        refreshControl?.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)

    }
    
    func refreshData() {
        self.blockListArray = getBlockListArray()
        
        writeFile()
        
        //refreshBlockList()
        
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

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in

            let currIndex = indexPath.row
            let currItem = indexPath.item
            
            var currentArry = self.getBlockListArray()
            
            currentArry.removeAtIndex(currIndex)
            
            self.blockListArray = currentArry
            
            // Set arrary to NSDefaults
            self.defaults!.setObject(currentArry, forKey: self.blockListKey)
            
            tableView.reloadData()
        })
        
        delete.backgroundColor = UIColor.redColor()
        
        return [delete]
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
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {

            let path = ((NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString).stringByAppendingPathComponent("blockerList") as NSString).stringByAppendingPathExtension("json")!
            
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

                    print(path)
                    let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)

                    try jsonData!.writeToFile(path, atomically: false)
                    
                    SFContentBlockerManager.reloadContentBlockerWithIdentifier("\(NSBundle.mainBundle().bundleIdentifier).ContentBlocker",
                        completionHandler: { (error) in
                            print ("SFContentBlockerManager.reloadContentBlockerWithIdentifier")
                            print (error)
                            print (error?.localizedDescription)
                    })
                    
                    // Set last update
                    let currentDate = NSDate()
                    defaults!.setObject(currentDate, forKey: lastJsonUpdated)
                }
                catch let error {
                    assertionFailure("Could not modify the blockerList: \(error)")
                }
            }
            else {
                print("List up to date")
                SFContentBlockerManager.reloadContentBlockerWithIdentifier("\(NSBundle.mainBundle().bundleIdentifier).ContentBlocker",
                    completionHandler: { (error) in
                        print ("SFContentBlockerManager.reloadContentBlockerWithIdentifier")
                        print (error)
                        print (error?.localizedDescription)
                })
            }
        }
    }
    
    func buildRulesJson() -> String {
        
        let blockListArray = getBlockListArray()
        var stringOfJson = ""
        
        // prefix of [
        stringOfJson = "[{\"action\": {\"type\": \"block\"}, \"trigger\": {\"url-filter\": \".*\", \"resource-type\": [\"script\"], \"load-type\": [\"third-party\"], \"if-domain\": [\"" + blockListArray.joinWithSeparator(", ") + "\"]}}]"
        
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
    
    func checkBlockFile() {
        let documentsPath = ((NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as NSString).stringByAppendingPathComponent("blockerList") as NSString).stringByAppendingPathExtension("json")!
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(documentsPath) {
            // Create file
            writeFile()
        }
    }
    
}
